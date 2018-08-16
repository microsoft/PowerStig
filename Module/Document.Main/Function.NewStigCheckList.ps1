<#
    .SYNOPSIS
        Automatically creates a Stig Viewer checklist from the DSC results or
        compiled MOF
    .PARAMETER ReferenceConfiguration
        The MOF that was compiled with a PowerStig composite
    .PARAMETER DscResult
        The resutls of Test-DscConfiguration
    .PARAMETER XccdfPath
        The path to the matching xccdf file. This is currently needed since we
        do not pull add xccdf data into PowerStig
    .PARAMETER OutputPath
        The location you want the checklist saved to
    .PARAMETER Enforcement
         Flag to add additional checklist metadata
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

    $writer.WriteEndElement(<#ASSET#>)
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
            $writer.WriteEndElement(<#SID_NAME#>)

            $writer.WriteStartElement('SID_DATA')
            $writer.WriteString($StigInfoElement.value)
            $writer.WriteEndElement(<#SID_DATA#>)

        $writer.WriteEndElement(<#SI_DATA#>)
    }

    $writer.WriteEndElement(<#STIG_INFO#>)

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

            $writer.WriteEndElement(<#STIG_DATA#>)
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
        $writer.WriteEndElement(<#STATUS#>)

        $writer.WriteStartElement("FINDING_DETAILS")
        $writer.WriteString( ( Get-FindingDetails -Setting $setting ) )
        $writer.WriteEndElement(<#FINDING_DETAILS#>)

        $writer.WriteStartElement("COMMENTS")
        $writer.WriteString($comments)
        $writer.WriteEndElement(<#COMMENTS#>)

        $writer.WriteStartElement("SEVERITY_OVERRIDE")
        $writer.WriteString('')
        $writer.WriteEndElement(<#SEVERITY_OVERRIDE#>)

        $writer.WriteStartElement("SEVERITY_JUSTIFICATION")
        $writer.WriteString('')
        $writer.WriteEndElement(<#SEVERITY_JUSTIFICATION#>)

        $writer.WriteEndElement(<#VULN#>)
    }
    #endregion

    $writer.WriteEndElement(<#iSTIG#>)
    $writer.WriteEndElement(<#STIGS#>)
    $writer.WriteEndElement(<#CHECKLIST#>)
    $writer.Flush()
    $writer.Close()
}

<#
    .SYNOPSIS
        Gets the vulnerability details from the rule description
#>
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

<#
    .SYNOPSIS
        Converts the mof into an array of objects
#>
function Get-MofContent
{
    [cmdletbinding()]
    [outputtype([psobject])
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

<#
    .SYNOPSIS
        Gets the stig details from the mof
#>
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

<#
    .SYNOPSIS
        Gets the stig details from the Test\Get-DscConfiguration output
#>
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
        Gets the value from a STIG setting
#>
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
