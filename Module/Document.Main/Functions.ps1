# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
# Header

<#
    .SYNOPSIS
        Automatically creates a Stig Viewer checklist from the DSC results or
        compiled MOF

    .PARAMETER ReferenceConfiguration
        The MOF that was compiled with a PowerStig composite

    .PARAMETER DscResult
        The results of Test-DscConfiguration

    .PARAMETER XccdfPath
        The path to the matching xccdf file. This is currently needed since we
        do not pull add xccdf data into PowerStig

    .PARAMETER OutputPath
        The location you want the checklist saved to

    .EXAMPLE
        New-StigCheckList -ReferenceConfiguration $ReferenceConfiguration -XccdfPath $XccdfPath -OutputPath $outputPath
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
        [System.Collections.ArrayList]
        $DscResult,

        [Parameter(Mandatory = $true)]
        [string]
        $XccdfPath,

        [Parameter(Mandatory = $true)]
        [string]
        $OutputPath
    )

    $xmlWriterSettings = [System.Xml.XmlWriterSettings]::new()
    $xmlWriterSettings.Indent = $true
    $xmlWriterSettings.IndentChars = "`t"
    $xmlWriterSettings.NewLineChars = "`n"
    $writer = [System.Xml.XmlWriter]::Create($OutputPath, $xmlWriterSettings)

    $writer.WriteStartElement('CHECKLIST')

    #region ASSET

    $writer.WriteStartElement("ASSET")

    $assetElements = [ordered] @{
        'ROLE' = 'None'
        'ASSET_TYPE' = 'Computing'
        'HOST_NAME' = ''
        'HOST_IP' = ''
        'HOST_MAC' = ''
        'HOST_GUID' = ''
        'HOST_FQDN' = ''
        'TECH_AREA' = ''
        'TARGET_KEY' = '2350'
        'WEB_OR_DATABASE' = 'false'
        'WEB_DB_SITE' = ''
        'WEB_DB_INSTANCE' = ''
    }

    foreach ($assetElement in $assetElements.GetEnumerator())
    {
        $writer.WriteStartElement($assetElement.name)
        $writer.WriteString($assetElement.value)
        $writer.WriteEndElement()
    }

    $writer.WriteEndElement(<#ASSET#>)

    #endregion ASSET

    $writer.WriteStartElement("STIGS")
    $writer.WriteStartElement("iSTIG")

    #region STIGS/iSTIG/STIG_INFO

    $writer.WriteStartElement("STIG_INFO")

    $xccdfBenchmarkContent = Get-StigXccdfBenchmarkContent -Path $XccdfPath

    $StigInfoElements = [ordered] @{
        'version'        = $xccdfBenchmarkContent.version
        'classification' = 'UNCLASSIFIED'
        'customname'     = ''
        'stigid'         = $xccdfBenchmarkContent.id
        'description'    = $xccdfBenchmarkContent.description
        'filename'       = Split-Path -Path $XccdfPath -Leaf
        'releaseinfo'    = $xccdfBenchmarkContent.'plain-text'.InnerText
        'title'          = $xccdfBenchmarkContent.title
        'uuid'           = (New-Guid).Guid
        'notice'         = $xccdfBenchmarkContent.notice.InnerText
        'source'         = $xccdfBenchmarkContent.reference.source
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

    #endregion STIGS/iSTIG/STIG_INFO

    #region STIGS/iSTIG/VULN[]

    foreach ( $vulnerability in (Get-VulnerabilityList -XccdfBenchmark $xccdfBenchmarkContent) )
    {
        $writer.WriteStartElement("VULN")

        foreach ($attribute in $vulnerability.GetEnumerator())
        {
            $status   = $null
            $comments = $null

            if ($attribute.Name -eq 'Vuln_Num')
            {
                $vid = $attribute.Value
            }

            $writer.WriteStartElement("STIG_DATA")

            $writer.WriteStartElement("VULN_ATTRIBUTE")
            $writer.WriteString($attribute.Name)
            $writer.WriteEndElement(<#VULN_ATTRIBUTE#>)

            $writer.WriteStartElement("ATTRIBUTE_DATA")
            $writer.WriteString($attribute.Value)
            $writer.WriteEndElement(<#ATTRIBUTE_DATA#>)

            $writer.WriteEndElement(<#STIG_DATA#>)
        }

        $statusMap = @{
            NotReviewed = 'Not_Reviewed'
            Open = 'Open'
            NotAFinding = 'NotAFinding'
            NotApplicable = 'Not_Applicable'
        }

        if ($PSCmdlet.ParameterSetName -eq 'mof')
        {
            $setting = Get-SettingsFromMof -ReferenceConfiguration $ReferenceConfiguration -Id $vid

            if ($setting)
            {
                $status = $statusMap['NotAFinding']
                $comments = 'Managed via PowerStigDsc'
            }
            else
            {
                $status = $statusMap['NotReviewed']
            }
        }
        elseif ($PSCmdlet.ParameterSetName -eq 'result')
        {
            $setting = Get-SettingsFromResult -DscResult $DscResult -Id $vid

            if ($setting)
            {
                if ($setting.InDesiredState)
                {
                    $status = $statusMap['NotAFinding']
                }
                else
                {
                    $status = $statusMap['Open']
                }

                $comments = 'Managed via PowerStigDsc from Live call'
            }
            else
            {
                $status = $statusMap['NotReviewed']
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

    #endregion STIGS/iSTIG/VULN[]

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
        [Parameter()]
        [psobject]
        $XccdfBenchmark
    )

    [System.Collections.ArrayList] $vulnerabilityList = @()

    foreach ( $vulnerability in $XccdfBenchmark.Group )
    {
        [xml]$vulnerabiltyDiscussionElement = "<discussionroot>$($vulnerability.Rule.description)</discussionroot>"

        [void] $vulnerabilityList.Add(
            @(
                [PSCustomObject]@{ Name = 'Vuln_Num'; Value = $vulnerability.id },
                [PSCustomObject]@{ Name = 'Severity'; Value= $vulnerability.Rule.severity},
                [PSCustomObject]@{ Name = 'Group_Title'; Value = $vulnerability.title},
                [PSCustomObject]@{ Name = 'Rule_ID'; Value = $vulnerability.Rule.id},
                [PSCustomObject]@{ Name = 'Rule_Ver'; Value = $vulnerability.Rule.version},
                [PSCustomObject]@{ Name = 'Rule_Title'; Value = $vulnerability.Rule.title},
                [PSCustomObject]@{ Name = 'Vuln_Discuss'; Value = $vulnerabiltyDiscussionElement.discussionroot.VulnDiscussion},
                [PSCustomObject]@{ Name = 'IA_Controls'; Value = $vulnerabiltyDiscussionElement.discussionroot.IAControls},
                [PSCustomObject]@{ Name = 'Check_Content'; Value = $vulnerability.Rule.check.'check-content'},
                [PSCustomObject]@{ Name = 'Fix_Text'; Value = $vulnerability.Rule.fixtext.InnerText},
                [PSCustomObject]@{ Name = 'False_Positives'; Value = $vulnerabiltyDiscussionElement.discussionroot.FalsePositives},
                [PSCustomObject]@{ Name = 'False_Negatives'; Value = $vulnerabiltyDiscussionElement.discussionroot.FalseNegatives},
                [PSCustomObject]@{ Name = 'Documentable'; Value = $vulnerabiltyDiscussionElement.discussionroot.Documentable},
                [PSCustomObject]@{ Name = 'Mitigations'; Value = $vulnerabiltyDiscussionElement.discussionroot.Mitigations},
                [PSCustomObject]@{ Name = 'Potential_Impact'; Value = $vulnerabiltyDiscussionElement.discussionroot.PotentialImpacts},
                [PSCustomObject]@{ Name = 'Third_Party_Tools'; Value = $vulnerabiltyDiscussionElement.discussionroot.ThirdPartyTools},
                [PSCustomObject]@{ Name = 'Mitigation_Control'; Value = $vulnerabiltyDiscussionElement.discussionroot.MitigationControl},
                [PSCustomObject]@{ Name = 'Responsibility'; Value = $vulnerabiltyDiscussionElement.discussionroot.Responsibility},
                [PSCustomObject]@{ Name = 'Security_Override_Guidance'; Value = $vulnerabiltyDiscussionElement.discussionroot.SeverityOverrideGuidance},
                [PSCustomObject]@{ Name = 'Check_Content_Ref'; Value = $vulnerability.Rule.check.'check-content-ref'.href },
                [PSCustomObject]@{ Name = 'Weight'; Value = $vulnerability.Rule.Weight},
                [PSCustomObject]@{ Name = 'Class'; Value = 'Unclass'},
                [PSCustomObject]@{ Name = 'STIGRef'; Value = "$($XccdfBenchmark.title) :: $($XccdfBenchmark.'plain-text'.InnerText)"},
                [PSCustomObject]@{ Name = 'TargetKey'; Value = $vulnerability.Rule.reference.identifier}

                # Some Stigs have multiple Control Correlation Identifiers (CCI)
                $(
                    # Extract only the cci entries
                    $CCIREFList = $vulnerability.Rule.ident |
                        Where-Object {$PSItem.system -eq 'http://iase.disa.mil/cci'} |
                            Select-Object 'InnerText' -ExpandProperty 'InnerText'

                    foreach ($CCIREF in $CCIREFList)
                    {
                        [PSCustomObject]@{ Name = 'CCI_REF'; Value = $CCIREF}
                    }
                )
            )
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
    [CmdletBinding()]
    [OutputType([psobject])]
    param
    (
        [Parameter(Mandatory = $true)]
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
    [CmdletBinding()]
    [OutputType([psobject])]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $ReferenceConfiguration,

        [Parameter(Mandatory = $true)]
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
    [CmdletBinding()]
    [OutputType([psobject])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Collections.ArrayList]
        $DscResult,

        [Parameter(Mandatory = $true)]
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
        {$PSItem -match "^\[(x)?Registry\]"}
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
