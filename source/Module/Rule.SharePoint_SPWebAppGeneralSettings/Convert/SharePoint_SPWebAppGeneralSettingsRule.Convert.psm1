# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\..\Common\Common.psm1
using module .\..\SharePoint_SPWebAppGeneralSettingsRule.psm1


$exclude = @($MyInvocation.MyCommand.Name,'Template.*.txt')
$supportFileList = Get-ChildItem -Path $PSScriptRoot -Exclude $exclude
foreach ($supportFile in $supportFileList)
{
    Write-Verbose "Loading $($supportFile.FullName)"
    . $supportFile.FullName
}
# Header

<#
    .SYNOPSIS
        
    .DESCRIPTION
        
#>
Class SharePoint_SPWebAppGeneralSettingsRuleConvert : SharePoint_SPWebAppGeneralSettingsRule
{
    <#
        .SYNOPSIS
            Empty constructor for SplitFactory
    #>
    SharePoint_SPWebAppGeneralSettingsRuleConvert ()
    {
    }

    <#
        .SYNOPSIS
            Converts a xccdf stig rule element into a SharePoint Rule
        .PARAMETER XccdfRule
            The STIG rule to convert
    #>
    SharePoint_SPWebAppGeneralSettingsRuleConvert ([xml.xmlelement] $XccdfRule) : Base ($XccdfRule, $true)
    {
        $this.PropertyName = $this.GetPropertyName($this.SplitCheckContent)
        $this.PropertyValue = $this.GetPropertyValue($this.SplitCheckContent)



        <# $ruleType = $this.GetRuleType($this.splitCheckContent)
        $fixText = [SharePoint_SPWebAppGeneralSettingsRule]::GetFixText($XccdfRule)
        
        if ($this.conversionstatus -eq 'pass')
        {
            $this.SetDuplicateRule()
        }

        $this.GetProperty($ruleType)
        
        $this.TestProperty($ruleType)
        $this.SetProperty($ruleType, $fixText) #>
        
        
        <# $this.SetVariable($ruleType)
        $this.SetDuplicateRule()
        $this.SetDscResource() #>
    }


    


# 

 <#
        .SYNOPSIS
            Extracts the get Property from the check-content and sets the value
        .DESCRIPTION
            Gets the get Property from the xccdf content and sets the value. If
            the Property that is returned is not valid, the parser status is set
            to fail.
        .PARAMETER RuleType
            The type of rule to get the get Property for
    #>
    [void] GetProperty ([string] $RuleType)
    {
        $thisGetProperty = & Get-$($RuleType)GetProperty -CheckContent $this.SplitCheckContent

        if (-not $this.SetStatus($thisGetProperty))
        {
            $this.set_GetProperty($thisGetProperty)
        }
    }

    <#
        .SYNOPSIS
            Extracts the test Property from the check-content and sets the value
        .DEPropertyION
            Gets the test Property from the xccdf content and sets the value. If
            the Property that is returned is not valid, the parser status is set
            to fail.
        .PARAMETER RuleType
            The type of rule to get the test Property for
    #>
    [void] TestProperty ($RuleType)
    {
        $thisTestProperty = & Get-$($RuleType)TestProperty -CheckContent $this.SplitCheckContent

        if (-not $this.SetStatus($thisTestProperty))
        {
            $this.set_TestProperty($thisTestProperty)
        }
    }

    <#
        .SYNOPSIS
            Extracts the set Property from the check-content and sets the value
        .DESCRIPTION
            Gets the set Property from the xccdf content and sets the value. If
            the Property that is returned is not valid, the parser status is set
            to fail.
        .PARAMETER RuleType
            The type of rule to get the set Property for
        .PARAMETER FixText
            The set Property to run
    #>
    [void] SetProperty ([string] $RuleType, [string[]] $FixText)
    {
        $checkContent = $this.SplitCheckContent

        $thisSetProperty = & Get-$($RuleType)SetProperty -FixText $FixText -CheckContent $checkContent

        if (-not $this.SetStatus($thisSetProperty))
        {
            $this.set_SetProperty($thisSetProperty)
        }
    }

    <#
        .SYNOPSIS
            Extracts the variable
        .DESCRIPTION
            Gets the variable string to be used in the SharePoint resource
        .PARAMETER RuleType
            The type of rule to get the variable string for.
    #>

    [void] SetVariable ([string] $RuleType)
    {
        if (Test-VariableRequired -Rule $this.id)
        {
            $thisVariable = & Get-$($RuleType)Variable
            $this.set_Variable($thisVariable)

            # If a SharePointRule has a value in the variable property then it requires an OrgValue
            $this.Set_OrganizationValueRequired($true)
        }
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
        $ruleType = "SharePoint_SPWebAppGeneralSettings"

        return $ruleType
    }

    hidden [void] SetDscResource ()
    {
        if($null -eq $this.DuplicateOf)
        {
            $this.DscResource = 'SharePoint_SPWebAppGeneralSettings'
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

    #endregion


    [string] GetPropertyName([string]$CheckContent)
    {

        $PropertyName = ''
        if ($CheckContent -Match "prohibited mobile code")
        {
            $PropertyName = 'AllowOnlineWebPartCatalog'
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

    #[string] GetPropertyValue ([string]$CheckContent, [string]$OrgSettings)
    [string] GetPropertyValue ([string] $CheckContent)
    {
        $PropertyValue = 'Blah'

        return $PropertyValue
        
    }


<# Static[string] Test-VariableRequired([string]$Rule)
{
    $requiresVariableList = @(
        ''
    )

    return ($Rule -in $requiresVariableList)
} #>

}