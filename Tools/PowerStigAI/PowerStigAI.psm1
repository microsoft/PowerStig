function ConvertFrom-SecureToken
{
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $true)]
        [securestring]
        $Token
    )

    $tokenPointer = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($Token)
    try
    {
        return [Runtime.InteropServices.Marshal]::PtrToStringBSTR($tokenPointer)
    }
    finally
    {
        [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($tokenPointer)
    }
}

function Get-PowerStigAiAccessToken
{
    [CmdletBinding()]
    [OutputType([securestring])]
    param ()

    if (-not (Get-Command -Name Get-AzAccessToken -ErrorAction SilentlyContinue))
    {
        throw 'Az.Accounts is required. Install it and run Connect-AzAccount before using Azure AI.'
    }

    return (Get-AzAccessToken -ResourceUrl 'https://ai.azure.com').Token
}

function Get-PowerStigBatchDocumentReport
{
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $Archive,

        [Parameter(Mandatory = $true)]
        [string]
        $XccdfPath,

        [Parameter(Mandatory = $true)]
        [string]
        $ConvertedPath
    )

    [xml] $sourceXml = Get-Content -Path $XccdfPath -Encoding UTF8 -Raw
    [xml] $convertedXml = Get-Content -Path $ConvertedPath -Encoding UTF8 -Raw
    $sourceRuleIds = @($sourceXml.Benchmark.Group.Id)
    $convertedRuleGroups = @(
        $convertedXml.SelectNodes('//Rule') |
        Group-Object -Property { ([string] $PSItem.Id -split '\.')[0] }
    )
    $convertedRuleIds = @($convertedRuleGroups.Name)
    $convertedRules = @($convertedXml.SelectNodes('//Rule'))
    $automatedConvertedRuleIds = @(
        $convertedRules |
        Where-Object {
            $PSItem.ConversionStatus -eq 'pass' -and
            $PSItem.ParentNode.Name -notin @('DocumentRule', 'ManualRule') -and
            -not [string]::IsNullOrWhiteSpace([string] $PSItem.DscResource) -and
            $PSItem.DscResource -ne 'None'
        } |
        Select-Object -ExpandProperty Id
    )
    do
    {
        $automatedCount = $automatedConvertedRuleIds.Count
        $automatedConvertedRuleIds = @(
            $automatedConvertedRuleIds
            $convertedRules |
            Where-Object {
                $PSItem.ConversionStatus -eq 'pass' -and
                -not [string]::IsNullOrWhiteSpace([string] $PSItem.DuplicateOf) -and
                $PSItem.DuplicateOf -in $automatedConvertedRuleIds
            } |
            Select-Object -ExpandProperty Id
        ) | Select-Object -Unique
    }
    while ($automatedConvertedRuleIds.Count -gt $automatedCount)
    $automatedRuleIds = @(
        $automatedConvertedRuleIds |
        ForEach-Object { ([string] $PSItem -split '\.')[0] } |
        Select-Object -Unique
    )
    $failedRuleIds = @(
        $convertedRuleGroups |
        Where-Object {
            @($PSItem.Group | Where-Object { $PSItem.ConversionStatus -ne 'pass' }).Count -gt 0
        } |
        Select-Object -ExpandProperty Name
    )
    $manualRuleIds = @(
        $convertedRuleGroups |
        Where-Object {
            $PSItem.Name -in $sourceRuleIds -and
            $PSItem.Name -notin $failedRuleIds -and
            $PSItem.Name -notin $automatedRuleIds
        } |
        Select-Object -ExpandProperty Name
    )
    $successfulRuleIds = @(
        $sourceRuleIds |
        Where-Object { $PSItem -in $convertedRuleIds -and $PSItem -notin $failedRuleIds -and $PSItem -notin $manualRuleIds }
    )
    $documentaryRuleIds = @(
        $convertedRuleGroups |
        Where-Object {
            $PSItem.Name -in $manualRuleIds -and
            'DocumentRule' -in @($PSItem.Group.ParentNode.Name)
        } |
        Select-Object -ExpandProperty Name
    )
    $manualFallbackRuleIds = @(
        $convertedRuleGroups |
        Where-Object {
            $PSItem.Name -in $manualRuleIds -and
            $PSItem.Name -notin $documentaryRuleIds -and
            'ManualRule' -in @($PSItem.Group.ParentNode.Name)
        } |
        Select-Object -ExpandProperty Name
    )
    $typedUnenforcedRuleIds = @(
        $manualRuleIds |
        Where-Object { $PSItem -notin $documentaryRuleIds -and $PSItem -notin $manualFallbackRuleIds }
    )
    $missingRuleIds = @($sourceRuleIds | Where-Object { $PSItem -notin $convertedRuleIds })

    return [pscustomobject] @{
        Archive              = $Archive
        Xccdf                = Split-Path -Path $XccdfPath -Leaf
        Output               = $ConvertedPath
        SourceRules          = $sourceRuleIds.Count
        SuccessfulRules      = $successfulRuleIds.Count
        ManualRules          = $manualRuleIds.Count
        NonAutomatedRules    = $manualRuleIds.Count
        DocumentaryRules     = $documentaryRuleIds.Count
        ManualFallbackRules  = $manualFallbackRuleIds.Count
        TypedUnenforcedRules = $typedUnenforcedRuleIds.Count
        FailedRules          = $failedRuleIds.Count
        MissingRules         = $missingRuleIds.Count
        FailedRuleIds        = $failedRuleIds
        MissingRuleIds       = $missingRuleIds
    }
}

function Convert-PowerStigZipFolder
{
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateScript({ Test-Path -Path $_ -PathType Container })]
        [string]
        $Path,

        [Parameter()]
        [string]
        $Destination = (Join-Path -Path $Path -ChildPath 'conversions'),

        [Parameter()]
        [string]
        $ChangeLogPath = (Join-Path -Path $PSScriptRoot -ChildPath '..\..\source\StigData\Archive'),

        [Parameter()]
        [scriptblock]
        $FallbackConverter,

        [Parameter()]
        [scriptblock]
        $ManualRuleReviewer,

        [Parameter(DontShow)]
        [scriptblock]
        $Converter = { param($Parameters) ConvertTo-PowerStigXml @Parameters }
    )

    $sourcePath = (Resolve-Path -Path $Path).Path
    $null = New-Item -Path $Destination -ItemType Directory -Force
    $destinationPath = (Resolve-Path -Path $Destination).Path
    $archives = @(Get-ChildItem -Path $sourcePath -Filter '*.zip' -File | Sort-Object -Property Name)
    $batchResults = [System.Collections.Generic.List[object]]::new()
    $documentReports = [System.Collections.Generic.List[object]]::new()
    $resolvedChangeLogPath = if (Test-Path -Path $ChangeLogPath -PathType Container)
    {
        (Resolve-Path -Path $ChangeLogPath).Path
    }

    foreach ($archive in $archives)
    {
        $extractPath = Join-Path -Path ([IO.Path]::GetTempPath()) -ChildPath "PowerStig-$([guid]::NewGuid())"
        try
        {
            Expand-Archive -Path $archive.FullName -DestinationPath $extractPath -Force
            $xccdfFiles = @(Get-ChildItem -Path $extractPath -Filter '*-xccdf.xml' -File -Recurse)

            if ($xccdfFiles.Count -eq 0)
            {
                $batchResults.Add([pscustomobject] @{
                        Archive     = $archive.FullName
                        Xccdf       = $null
                        Status      = 'Skipped'
                        Destination = $destinationPath
                        Error       = 'No XCCDF file was found in the archive.'
                    })
                continue
            }

            foreach ($xccdfFile in $xccdfFiles)
            {
                if ($resolvedChangeLogPath)
                {
                    $changeLog = Get-ChildItem -Path $resolvedChangeLogPath `
                        -Filter "$($xccdfFile.BaseName).log" -File -Recurse | Select-Object -First 1
                    if ($changeLog)
                    {
                        Copy-Item -Path $changeLog.FullName `
                            -Destination ([IO.Path]::ChangeExtension($xccdfFile.FullName, '.log'))
                    }
                }

                $conversionParameters = @{
                    Path        = $xccdfFile.FullName
                    Destination = $destinationPath
                }

                if ($FallbackConverter)
                {
                    $conversionParameters.FallbackConverter = $FallbackConverter
                }

                if ($ManualRuleReviewer)
                {
                    $conversionParameters.ManualRuleReviewer = $ManualRuleReviewer
                }

                try
                {
                    $converterOutput = @(& $Converter $conversionParameters)
                    $convertedPath = $converterOutput |
                    Where-Object { $PSItem -match '^Converted Output:\s*(.+)$' } |
                    ForEach-Object { $Matches[1] } |
                    Select-Object -Last 1
                    if ($convertedPath -and (Test-Path -Path $convertedPath -PathType Leaf))
                    {
                        $documentReports.Add((Get-PowerStigBatchDocumentReport `
                                    -Archive $archive.FullName -XccdfPath $xccdfFile.FullName `
                                    -ConvertedPath $convertedPath))
                    }

                    $batchResults.Add([pscustomobject] @{
                            Archive     = $archive.FullName
                            Xccdf       = $xccdfFile.Name
                            Status      = 'Converted'
                            Destination = $destinationPath
                            Error       = $null
                        })
                }
                catch
                {
                    $batchResults.Add([pscustomobject] @{
                            Archive     = $archive.FullName
                            Xccdf       = $xccdfFile.Name
                            Status      = 'Failed'
                            Destination = $destinationPath
                            Error       = $_.Exception.Message
                        })
                }
            }
        }
        catch
        {
            $batchResults.Add([pscustomobject] @{
                    Archive     = $archive.FullName
                    Xccdf       = $null
                    Status      = 'Failed'
                    Destination = $destinationPath
                    Error       = $_.Exception.Message
                })
        }
        finally
        {
            if (Test-Path -Path $extractPath)
            {
                Remove-Item -Path $extractPath -Recurse -Force
            }
        }
    }

    $report = [ordered] @{
        GeneratedAt = (Get-Date -Format o)
        SourcePath  = $sourcePath
        Destination = $destinationPath
        Totals      = [ordered] @{
            Archives             = $archives.Count
            Documents            = $documentReports.Count
            SourceRules          = ($documentReports.SourceRules | Measure-Object -Sum).Sum
            SuccessfulRules      = ($documentReports.SuccessfulRules | Measure-Object -Sum).Sum
            ManualRules          = ($documentReports.ManualRules | Measure-Object -Sum).Sum
            NonAutomatedRules    = ($documentReports.NonAutomatedRules | Measure-Object -Sum).Sum
            DocumentaryRules     = ($documentReports.DocumentaryRules | Measure-Object -Sum).Sum
            ManualFallbackRules  = ($documentReports.ManualFallbackRules | Measure-Object -Sum).Sum
            TypedUnenforcedRules = ($documentReports.TypedUnenforcedRules | Measure-Object -Sum).Sum
            FailedRules          = ($documentReports.FailedRules | Measure-Object -Sum).Sum
            MissingRules         = ($documentReports.MissingRules | Measure-Object -Sum).Sum
        }
        Documents   = @($documentReports)
        Archives    = @($batchResults)
    }
    $report | ConvertTo-Json -Depth 8 |
    Set-Content -Path (Join-Path -Path $destinationPath -ChildPath 'conversion-report.json') -Encoding UTF8

    return $batchResults
}

function Invoke-PowerStigAzureAiNormalization
{
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param
    (
        [Parameter(Mandatory = $true)]
        [psobject]
        $Context,

        [Parameter(Mandatory = $true)]
        [uri]
        $Endpoint,

        [Parameter(Mandatory = $true)]
        [string]
        $DeploymentName,

        [Parameter()]
        [securestring]
        $AccessToken
    )

    if (-not $AccessToken)
    {
        $AccessToken = Get-PowerStigAiAccessToken
    }

    $rule = $Context.XccdfRule.Rule
    $input = [ordered] @{
        RuleId        = $Context.XccdfRule.Id
        Title         = $rule.title
        CheckContent  = $rule.Check.'check-content'
        FixText       = $rule.fixtext.'#text'
        FailureReason = $Context.Reason
        FailureError  = if ($Context.Error) { $Context.Error.Exception.Message } else { $null }
    } | ConvertTo-Json -Depth 5

    $schema = [ordered] @{
        type                 = 'object'
        properties           = [ordered] @{
            correctedCheckContent = @{type = 'string' }
            correctedFixText      = @{type = 'string' }
            changes               = @{type = 'array'; items = @{type = 'string' } }
            confidence            = @{type = 'string'; enum = @('low', 'medium', 'high') }
        }
        required             = @('correctedCheckContent', 'correctedFixText', 'changes', 'confidence')
        additionalProperties = $false
    }

    $body = [ordered] @{
        model        = $DeploymentName
        store        = $false
        instructions = @'
Normalize the supplied DISA XCCDF rule so an existing deterministic parser can process it.
Preserve the security requirement exactly. Correct only malformed labels, separators, spacing,
and line breaks. Do not invent registry values, paths, or enforcement behavior. For Windows
registry settings, the corrected content must include canonical Registry Hive:, Registry Path:,
Value Name:, Type:, and Value: lines. If the source omits Type:, infer it only when the value
representation makes the registry type unambiguous, such as text data requiring REG_SZ, and
disclose that inference in changes. Otherwise preserve the omission and use low confidence.
Return only the fields required by the JSON schema.
'@
        input        = $input
        text         = @{
            format = @{
                type   = 'json_schema'
                name   = 'PowerStigXccdfNormalization'
                schema = $schema
                strict = $true
            }
        }
    } | ConvertTo-Json -Depth 10

    $requestUri = '{0}/responses' -f $Endpoint.AbsoluteUri.TrimEnd('/')
    $plainToken = ConvertFrom-SecureToken -Token $AccessToken
    try
    {
        $response = Invoke-RestMethod -Method Post -Uri $requestUri -Headers @{
            Authorization = "Bearer $plainToken"
        } -ContentType 'application/json' -Body $body
    }
    finally
    {
        $plainToken = $null
    }

    if ($response.status -and $response.status -ne 'completed')
    {
        throw "Azure AI response did not complete. Status: $($response.status)"
    }

    $outputText = $response.output_text
    if (-not $outputText)
    {
        $outputText = $response.output |
        Where-Object type -eq 'message' |
        ForEach-Object content |
        Where-Object type -eq 'output_text' |
        Select-Object -First 1 -ExpandProperty text
    }

    if (-not $outputText)
    {
        throw 'Azure AI response did not contain structured output text.'
    }

    $normalization = $outputText | ConvertFrom-Json
    if (-not $normalization.correctedCheckContent -or -not $normalization.correctedFixText)
    {
        throw 'Azure AI response omitted required normalized XCCDF content.'
    }

    return [pscustomobject] @{
        RuleId                = $Context.XccdfRule.Id
        CorrectedCheckContent = $normalization.correctedCheckContent
        CorrectedFixText      = $normalization.correctedFixText
        Changes               = @($normalization.changes)
        Confidence            = $normalization.confidence
        ResponseId            = $response.id
        Model                 = $response.model
    }
}

function Invoke-PowerStigAzureAiManualReview
{
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param
    (
        [Parameter(Mandatory = $true)]
        [psobject]
        $Context,

        [Parameter(Mandatory = $true)]
        [uri]
        $Endpoint,

        [Parameter(Mandatory = $true)]
        [string]
        $DeploymentName,

        [Parameter()]
        [securestring]
        $AccessToken
    )

    if (-not $AccessToken)
    {
        $AccessToken = Get-PowerStigAiAccessToken
    }

    $rule = $Context.XccdfRule.Rule
    $input = [ordered] @{
        RuleId       = $Context.XccdfRule.Id
        Title        = $rule.title
        CheckContent = $rule.Check.'check-content'
        FixText      = $rule.fixtext.'#text'
        CurrentType  = @($Context.Rules | ForEach-Object { $_.GetType().Name })
        ReviewReason = $Context.Reason
    } | ConvertTo-Json -Depth 5

    $schema = [ordered] @{
        type                 = 'object'
        properties           = [ordered] @{
            decision              = @{
                type = 'string'
                enum = @('manual', 'automation-gap', 'unsupported', 'uncertain')
            }
            suggestedRuleType     = @{type = @('string', 'null') }
            rationale             = @{type = 'string' }
            correctedCheckContent = @{type = 'string' }
            correctedFixText      = @{type = 'string' }
            changes               = @{type = 'array'; items = @{type = 'string' } }
            confidence            = @{type = 'string'; enum = @('low', 'medium', 'high') }
        }
        required             = @(
            'decision',
            'suggestedRuleType',
            'rationale',
            'correctedCheckContent',
            'correctedFixText',
            'changes',
            'confidence'
        )
        additionalProperties = $false
    }

    $body = [ordered] @{
        model        = $DeploymentName
        store        = $false
        instructions = @'
Review a DISA XCCDF rule that PowerSTIG classified as manual. Decide whether the requirement truly
requires human judgment, has an automation gap in the parser, needs a currently unsupported
PowerSTIG capability, or is uncertain. Use automation-gap only when normalized XCCDF text can be
converted to one or more of these existing types: AccountPolicyRule, AuditPolicyRule,
AuditSettingRule, DnsServerRootHintRule,
DnsServerSettingRule, DocumentRule, FileContentRule, GroupRule, HardCodedRule, IisLoggingRule,
MimeTypeRule, PermissionRule, ProcessMitigationRule, RegistryRule, RootCertificateRule,
OperatingSystemRule, SecurityOptionRule, ServiceRule, SqlDatabaseRule, SqlLoginRule, SqlProtocolRule, SqlScriptQueryRule,
SqlServerConfigurationRule, SslSettingsRule, UserRightRule, WebAppPoolRule,
WebConfigurationPropertyRule, WindowsFeatureRule, and WinEventLogRule. Use unsupported when a
deterministic check is possible but none of those types can preserve the complete requirement,
including applicability conditions. Never use automation-gap for a partial conversion: if any check,
exception, applicability condition, or remediation remains manual or cannot be represented by the
suggested type, use unsupported. Do not invent settings or claim that a DSC resource exists without
evidence in the supplied text. Normalize malformed labels, separators, spacing, and line breaks in
the corrected content while preserving the security requirement exactly. For an automation-gap,
set suggestedRuleType to the existing target type and format corrected content for that type.
Otherwise set suggestedRuleType to null. Automation-gap output will be retried through PowerSTIG
and accepted only when it produces passing non-manual typed rules.
'@
        input        = $input
        text         = @{
            format = @{
                type   = 'json_schema'
                name   = 'PowerStigManualRuleReview'
                schema = $schema
                strict = $true
            }
        }
    } | ConvertTo-Json -Depth 10

    $requestUri = '{0}/responses' -f $Endpoint.AbsoluteUri.TrimEnd('/')
    $plainToken = ConvertFrom-SecureToken -Token $AccessToken
    try
    {
        $response = Invoke-RestMethod -Method Post -Uri $requestUri -Headers @{
            Authorization = "Bearer $plainToken"
        } -ContentType 'application/json' -Body $body
    }
    finally
    {
        $plainToken = $null
    }

    if ($response.status -and $response.status -ne 'completed')
    {
        throw "Azure AI response did not complete. Status: $($response.status)"
    }

    $outputText = $response.output_text
    if (-not $outputText)
    {
        $outputText = $response.output |
        Where-Object type -eq 'message' |
        ForEach-Object content |
        Where-Object type -eq 'output_text' |
        Select-Object -First 1 -ExpandProperty text
    }

    if (-not $outputText)
    {
        throw 'Azure AI response did not contain structured output text.'
    }

    $review = $outputText | ConvertFrom-Json
    if (-not $review.decision -or -not $review.rationale)
    {
        throw 'Azure AI response omitted required manual review content.'
    }

    return [pscustomobject] @{
        RuleId                = $Context.XccdfRule.Id
        Decision              = $review.decision
        SuggestedRuleType     = $review.suggestedRuleType
        Rationale             = $review.rationale
        CorrectedCheckContent = $review.correctedCheckContent
        CorrectedFixText      = $review.correctedFixText
        Changes               = @($review.changes)
        Confidence            = $review.confidence
        ResponseId            = $response.id
        Model                 = $response.model
    }
}

Export-ModuleMember -Function @(
    'Convert-PowerStigZipFolder',
    'Invoke-PowerStigAzureAiNormalization',
    'Invoke-PowerStigAzureAiManualReview'
)