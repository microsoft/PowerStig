<#
    .SYNOPSIS
        Short description

    .DESCRIPTION
        Long description

    .PARAMETER ReferenceConfiguration
        Parameter description

    .PARAMETER DscResult
        Parameter description

    .PARAMETER XccdfPath
        Parameter description

    .PARAMETER OutputPath
        Parameter description

    .PARAMETER Enforcement
        Parameter description

    .EXAMPLE
        New-StigCheckList -ReferenceConfiguration $ReferenceConfiguration -XccdfPath $XccdfPath -OutputPath $outputPath -Enforcement DSC

#>
function New-StigCheckList
{
    [CmdletBinding()]
    [OutputType([xml])]
    param
    (
        [Parameter(Mandatory = $true, ParameterSetName = 'mof')]
        [string]
        $ReferenceConfiguration,

        [Parameter(Mandatory = $true, ParameterSetName = 'result')]
        [PSCustomObject]
        $DscResult,

        [parameter(Mandatory = $true)]
        [string]
        $XccdfPath,

        [parameter(Mandatory = $true)]
        [string]
        $OutputPath,

        [parameter(Mandatory = $true)]
        [ValidateSet('DSC', 'GPO')]
        [string]
        $Enforcement
    )

    #region Checklist Root

    # Start the XML doc
    $settings = [System.Xml.XmlWriterSettings]::new()
    $settings.Indent = $true
    $writer = [System.Xml.XmlWriter]::Create($OutputPath, $settings)

    $writer.WriteStartElement('CHECKLIST')

    $writer.WriteStartElement("ASSET")

    $assetElements = [ordered] @{
        'ROLE'            = 'None'
        'ASSET_TYPE'      = 'Computing'
        'HOST_NAME'       = ''
        'HOST_IP'         = ''
        'HOST_MAC'        = ''
        'HOST_GUID'       = ''
        'HOST_FQDN'       = ''
        'TECH_AREA'       = ''
        'TARGET_KEY'      = ''
        'WEB_OR_DATABASE' = $false
        'WEB_DB_SITE'     = ''
        'WEB_DB_INSTANCE' = ''
    }

    foreach ($assetElement in $assetElements.GetEnumerator())
    {
        $writer.WriteStartElement($assetElement.name)
        $writer.WriteString($assetElement.value)
        $writer.WriteEndElement()
    }
    # End ASSET
    $writer.WriteEndElement()

    $writer.WriteStartElement("STIGS")

    $writer.WriteStartElement("iSTIG")

    $writer.WriteStartElement("STIG_INFO")

    #endregion

    #region SI Data

    $xccdfBenchmarkContent = Get-StigXccdfBenchmarkContent -Path $XccdfPath

    $StigInfoElements = [ordered] @{
        'version'        = "$($xccdfBenchmarkContent.version)"
        'classification' = 'UNCLASSIFIED'
        'customname'     = ''
        'stigid'         = "$($xccdfBenchmarkContent.id)"
        'description'    = "$($xccdfBenchmarkContent.description)"
        'filename'       = "$(Split-Path -Path $XccdfPath -Leaf)"
        'releaseinfo'    = "$($xccdfBenchmarkContent.'plain-text'.InnerText)"
        'title'          = "$($xccdfBenchmarkContent.title)"
        'uuid'           = "$((New-Guid).Guid)"
        'notice'         = "$($xccdfBenchmarkContent.notice.InnerText)"
        'source'         = "$($xccdfBenchmarkContent.reference.source)"
    }

    foreach ($StigInfoElement in $StigInfoElements.GetEnumerator())
    {
        $writer.WriteStartElement("SI_DATA")

        $writer.WriteStartElement('SID_NAME')
        $writer.WriteString($StigInfoElement.name)
        $writer.WriteEndElement()

        $writer.WriteStartElement('SID_DATA')
        $writer.WriteString($StigInfoElement.value)
        $writer.WriteEndElement()

        # End SI_DATA
        $writer.WriteEndElement()
    }

    # End STIG_INFO
    $writer.WriteEndElement()

    #endregion


    #region Vulnerability

    $vulnerabilities = Get-VulnerabilityList -XccdfBenchmark $xccdfBenchmarkContent

    foreach ( $vulnerability in $vulnerabilities )
    {
        $writer.WriteStartElement("VULN")

        foreach ($attribute in $vulnerability.GetEnumerator())
        {
            $status = $null
            $comments = $null

            if ($attribute.Name -eq 'Vuln_Num')
            {
                $vid = $attribute.Value
            }

            $writer.WriteStartElement("STIG_DATA")

            $writer.WriteStartElement("VULN_ATTRIBUTE")
            $writer.WriteString($attribute.Name)
            $writer.WriteEndElement()

            $writer.WriteStartElement("ATTRIBUTE_DATA")
            $writer.WriteString($attribute.Value)
            $writer.WriteEndElement()

            # End STIG_DATA
            $writer.WriteEndElement()
        }

        if ($PSCmdlet.ParameterSetName -eq 'mof')
        {
            $setting = Get-SettingsFromMof -ReferenceConfiguration $ReferenceConfiguration -Id $vid

            if ($setting)
            {
                $status = 'NotAFinding'
                $comments = 'Managed via PowerStigDsc'
            }
            else
            {
                $status = 'NotReviewed'
            }
        }
        elseif ($PSCmdlet.ParameterSetName -eq 'result')
        {
            $setting = Get-SettingsFromResult -DscResult $DscResult -Id $vid

            if ($setting)
            {
                if ($setting.InDesiredState)
                {
                    $status = 'NotAFinding'
                }
                else
                {
                    $status = 'Open'
                }

                $comments = 'Managed via PowerStigDsc from Live call'
            }
            else
            {
                $status = 'NotReviewed'
            }
        }

        $writer.WriteStartElement("STATUS")
        $writer.WriteString($status)
        $writer.WriteEndElement()

        $writer.WriteStartElement("FINDING_DETAILS")
        $writer.WriteString( ( Get-FindingDetails -Setting $setting ) )
        $writer.WriteEndElement()

        $writer.WriteStartElement("COMMENTS")
        $writer.WriteString($comments)
        $writer.WriteEndElement()

        $writer.WriteStartElement("SEVERITY_OVERRIDE")
        $writer.WriteString('')
        $writer.WriteEndElement()

        $writer.WriteStartElement("SEVERITY_JUSTIFICATION")
        $writer.WriteString('')
        $writer.WriteEndElement()

        # End VULN
        $writer.WriteEndElement()
    }
    #endregion

    # End iSTIG
    $writer.WriteEndElement()
    # End STIGS
    $writer.WriteEndElement()
    #End CHECKLIST
    $writer.WriteEndElement()

    $writer.Flush()
    $writer.Close()
}

function Get-VulnerabilityList
{
    [CmdletBinding()]
    [OutputType([xml])]
    param
    (
        [parameter()]
        [psobject]
        $XccdfBenchmark
    )

    [System.Collections.ArrayList] $vulnerabilityList = @()

    foreach ( $vulnerability in $XccdfBenchmark.Group )
    {
        [xml]$vulnerabiltyDiscussionElement = "<discussionroot>$($vulnerability.Rule.description)</discussionroot>"

        [void] $vulnerabilityList.Add(
            [ordered]@{
                'Vuln_Num'                      = "$($vulnerability.id)"
                'Severity'                      = "$($vulnerability.Rule.severity)"
                'Group_Title'                   = "$($vulnerability.title)"
                'Rule_ID'                       = "$($vulnerability.Rule.id)"
                'Rule_Ver'                      = "$($vulnerability.Rule.version)"
                'Rule_Title'                    = "$($vulnerability.Rule.title)"
                'Vuln_Discuss'                  = "$($vulnerabiltyDiscussionElement.discussionroot.VulnDiscussion)"
                'IA_Controls'                   = "$($vulnerabiltyDiscussionElement.discussionroot.IAControls)"
                'Check_Content'                 = "$($vulnerability.Rule.check.'check-content')"
                'Fix_Text'                      = "$($vulnerability.Rule.fixtext.InnerText)"
                'False_Positives'               = "$($vulnerabiltyDiscussionElement.discussionroot.FalsePositives)"
                'False_Negatives'               = "$($vulnerabiltyDiscussionElement.discussionroot.FalseNegatives)"
                'Documentable'                  = "$($vulnerabiltyDiscussionElement.discussionroot.Documentable)"
                'Mitigations'                   = "$($vulnerabiltyDiscussionElement.discussionroot.Mitigations)"
                'Potential_Impact'              = "$($vulnerabiltyDiscussionElement.discussionroot.PotentialImpacts)"
                'Third_Party_Tools'             = "$($vulnerabiltyDiscussionElement.discussionroot.ThirdPartyTools)"
                'Mitigation_Control'            = "$($vulnerabiltyDiscussionElement.discussionroot.MitigationControl)"
                'Responsibility'                = "$($vulnerabiltyDiscussionElement.discussionroot.Responsibility)"
                'Security_Override_Guidance'    = "$($vulnerabiltyDiscussionElement.discussionroot.SeverityOverrideGuidance)"
                'Check_Content_Ref'             = "$($vulnerability.Rule.check.'check-content-ref'.href)"
                'Class'                         = 'Unclass'
                'STIGRef'                       = "$($XccdfBenchmark.title) :: $($XccdfBenchmark.'plain-text'.InnerText)"
                'TargetKey'                     = "$($vulnerability.Rule.reference.identifier)"
                'CCI_REF'                       = "$($vulnerability.Rule.ident.InnerText)"
            }
        )
    }

    return $vulnerabilityList
}

function Get-MofContent
{
    [cmdletbinding()]
    [outputtype([psobject])]
    param
    (
        [parameter(Mandatory = $true)]
        [string]
        $ReferenceConfiguration
    )

    if ( -not $script:mofContent )
    {
        $script:mofContent = [Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::ImportInstances($ReferenceConfiguration, 4)
    }

    return $script:mofContent
}

function Get-SettingsFromMof
{
    [cmdletbinding()]
    [outputtype([psobject])]
    param
    (
        [parameter(Mandatory = $true)]
        [string]
        $ReferenceConfiguration,

        [parameter(Mandatory = $true)]
        [string]
        $Id
    )

    $mofContent = Get-MofContent -ReferenceConfiguration $ReferenceConfiguration

    return $mofContent.Where( {$PSItem.ResourceID -match $Id} )
}

function Get-SettingsFromResult
{
    [cmdletbinding()]
    [outputtype([psobject])]
    param
    (
        [parameter(Mandatory = $true)]
        [PSCustomObject]
        $DscResult,

        [parameter(Mandatory = $true)]
        [string]
        $Id
    )

    if (-not $script:allResources)
    {
        $script:allResources = $DscResult.ResourcesNotInDesiredState + $DscResult.ResourcesInDesiredState
    }

    return $script:allResources.Where( {$PSItem.ResourceID -match $Id} )
}

<#
    .SYNOPSIS
    Returns the benchmark element from the xccdf xml document.

    .PARAMETER Path
    The literal path to the the zip file that contain the xccdf or the specifc xccdf file.

    .NOTES
    General notes
#>
function Get-StigXccdfBenchmarkContent
{
    [cmdletbinding()]
    [outputtype([xml])]
    param
    (
        [parameter(Mandatory = $true)]
        [string]
        $Path
    )

    if (-not (Test-Path -Path $Path))
    {
        Throw "The file $Path was not found"
    }

    if ($Path -like "*.zip")
    {
        [xml] $xccdfXmlContent = Get-StigContentFromZip -Path $Path
    }
    else
    {
        [xml] $xccdfXmlContent = Get-Content -Path $Path
    }

    if (Test-ValidXccdf -xccdfXmlContent $xccdfXmlContent )
    {
        $xccdfXmlContent.Benchmark
    }
    else
    {
        Throw "$Path does not contain valid xccdf xml."
    }
}

<#
    .SYNOPSIS
    Extracts the xccdf file from the zip file provided from the DISA website.

    .PARAMETER Path
    The literal path to the zip file.

    .NOTES
    General notes
#>
function Get-StigContentFromZip
{
    [cmdletbinding()]
    [outputtype([xml])]
    param
    (
        [parameter(Mandatory = $true)]
        [string]
        $Path
    )

    # Create a unique path in the users temp directory to expand the files to.
    $zipDestinationPath = "$((Split-Path -Path $Path -Leaf) -replace '.zip','').$((Get-Date).Ticks)"
    Expand-Archive -LiteralPath $filePath -DestinationPath $zipDestinationPath
    # Get the full path to teh extracted xccdf file.
    $xccdfPath = (
        Get-ChildItem -Path $zipDestinationPath -Filter "*Manual-xccdf.xml" -Recurse -Verbose
    ).fullName
    # Get the xccdf content before removing the content from disk.
    $xccdfContent = Get-Content -Path $xccdfPath
    # Cleanup to temp folder
    Remove-Item $zipDestinationPath -Recurse -Force

    $xccdfContent
}

<#
    .SYNOPSIS
    Validates that the specific child elements the conversion process needs are avaialbe.

    .PARAMETER xccdfXmlContent
    Parameter description

    .NOTES
    General notes
#>
function Test-ValidXccdf
{
    [cmdletbinding()]
    [outputtype([bool])]
    param
    (
        [parameter(Mandatory = $true)]
        [xml]
        $xccdfXmlContent
    )

    $isValidXccdf = $true

    if ($null -eq $xccdfXmlContent.Benchmark)
    {
        return $false
    }

    switch ($xccdfXmlContent.Benchmark)
    {
        {$null -eq $PSItem.title}
        {
            $isValidXccdf = $false
        }
        {$null -eq $PSItem.version}
        {
            $isValidXccdf = $false
        }
        {$null -eq $PSItem.Group}
        {
            $isValidXccdf = $false
        }
    }

    $isValidXccdf
}

function Get-FindingDetails
{
    [OutputType([string])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [AllowNull()]
        [psobject]
        $Setting
    )

    switch ($setting.ResourceID)
    {
        {$PSItem -match "^\[Registry\]"}
        {
            return "Registry Value = $($setting.ValueData)"
        }
        {$PSItem -match "^\[AuditPolicySubcategory\]"}
        {
            return "AuditPolicySubcategory AuditFlag = $($setting.AuditFlag)"
        }
        {$PSItem -match "^\[AccountPolicy\]"}
        {
            return "AccountPolicy = Needs work"
        }
        {$PSItem -match "^\[UserRightsAssignment\]"}
        {
            return "UserRightsAssignment Identity = $($setting.Identity)"
        }
        {$PSItem -match "^\[SecurityOption\]"}
        {
            return "SecurityOption = Needs work"
        }
        default
        {
            return "not found"
        }
    }
}

#endregion
