# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\..\Common\Common.psm1
using module .\..\SharePointSPWebAppGeneralSettingsRule.psm1

$exclude = @($MyInvocation.MyCommand.Name,'Template.*.txt')
$supportFileList = Get-ChildItem -Path $PSScriptRoot -Exclude $exclude
foreach ($supportFile in $supportFileList)
{
    Write-Verbose "Loading $($supportFile.FullName)"
    . $supportFile.FullName
}

<#
    .SYNOPSIS
        
    .DESCRIPTION
        
#>
class SharePointSPWebAppGeneralSettingsRuleConvert : SharePointSPWebAppGeneralSettingsRule
{
    <#
        .SYNOPSIS
            Empty constructor for SplitFactory
    #>
    SharePointSPWebAppGeneralSettingsRuleConvert ()
    {
    }

    <#
        .SYNOPSIS
            Converts a xccdf stig rule element into a SharePoint Rule
        .PARAMETER XccdfRule
            The STIG rule to convert
    #>
    SharePointSPWebAppGeneralSettingsRuleConvert ([xml.xmlelement] $XccdfRule) : base ($XccdfRule, $true)
    {
        $this.PropertyName = $this.GetPropertyName($this.SplitCheckContent)
        $this.PropertyValue = $this.GetPropertyValue($this.SplitCheckContent)
        $this.SetDuplicateRule()
        $this.SetDscResource()
    }

    <#
        .SYNOPSIS
            Extracts the rule type from the check-content and sets the value
        .DESCRIPTION
            Gets the rule type from the xccdf content and sets the value
        .PARAMETER CheckContent
            The rule text from the check-content element in the xccdf
    #>
    [string] GetRuleType ([string[]] $CheckContent)
    {
        $ruleType = "SharePointSPWebAppGeneralSettings"

        return $ruleType
    }

    hidden [void] SetDscResource ()
    {
        if ($null -eq $this.DuplicateOf)
        {
            $this.DscResource = 'SharePointSPWebAppGeneralSettings'
        }
        else
        {
            $this.DscResource = 'None'
        }
    }

    static [bool] Match ([string] $CheckContent)
    {
        if
        (
            $CheckContent -Match "prohibited mobile code" -or
            $CheckContent -Match "SharePoint server configuration to ensure a session lock" -or
            $CheckContent -Match "ensure user sessions are terminated upon user logoff" -or
            $CheckContent -Match "ensure access to the online web part gallery is configured"
        )
        {
            return $true
        }
        return $false
    }

    [string] GetPropertyName([string]$CheckContent)
    {
        $PropertyName = ''
        if ($CheckContent -Match "prohibited mobile code")
        {
            $PropertyName = 'BrowserFileHandling'
        }
        if ($CheckContent -Match "SharePoint server configuration to ensure a session lock")
        {
            $PropertyName = 'SecurityValidationTimeOutMinutes'
        }
        if ($CheckContent -Match "ensure user sessions are terminated upon user logoff")
        {
            $PropertyName = 'SecurityValidation'
        }
        if ($CheckContent -Match "ensure access to the online web part gallery is configured")
        {
            $PropertyName = 'AllowOnlineWebPartCatalog'
        }

        return $PropertyName
    }

    [string] GetPropertyValue ([string] $CheckContent)
    {
        $PropertyValue = ''
        if ($CheckContent -Match "set to expire after 15 minutes or less")
        {
            $CheckContentPattern = [regex]::new('((\d\d)(?=\sminutes of inactivity))')
            $myMatches = $CheckContentPattern.Matches($CheckContent)
            $PropertyValue = $myMatches.Value
        }
        if ($CheckContent -Match "ensure user sessions are terminated upon user logoff")
        {
            $PropertyValue = $true
        }
        if ($CheckContent -Match "ensure access to the online web part gallery is configured")
        {
            $PropertyValue = $false
        }
        if ($CheckContent -Match "prohibited mobile code")
        {
            $PropertyValue = "Strict"
        }
        
        return $PropertyValue
    }
}
