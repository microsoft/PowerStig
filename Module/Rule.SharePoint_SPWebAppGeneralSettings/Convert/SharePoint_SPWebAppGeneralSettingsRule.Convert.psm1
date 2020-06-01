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
        $ruleType = $this.GetRuleType($this.splitCheckContent)
        $fixText = [SharePoint_SPWebAppGeneralSettingsRule]::GetFixText($XccdfRule)

        if ($this.conversionstatus -eq 'pass')
        {
            $this.SetDuplicateRule()
        }

        $this.SetGetScript($ruleType)
        $this.SetTestScript($ruleType)
        $this.SetSetScript($ruleType, $fixText)
        $this.SetVariable($ruleType)
        $this.SetDuplicateRule()
        $this.SetDscResource()
    }


    


# 

 <#
        .SYNOPSIS
            Extracts the get script from the check-content and sets the value
        .DESCRIPTION
            Gets the get script from the xccdf content and sets the value. If
            the script that is returned is not valid, the parser status is set
            to fail.
        .PARAMETER RuleType
            The type of rule to get the get script for
    #>
    [void] SetGetScript ([string] $RuleType)
    {
        $thisGetScript = & Get-$($RuleType)GetScript -CheckContent $this.SplitCheckContent

        if (-not $this.SetStatus($thisGetScript))
        {
            $this.set_GetScript($thisGetScript)
        }
    }

    <#
        .SYNOPSIS
            Extracts the test script from the check-content and sets the value
        .DESCRIPTION
            Gets the test script from the xccdf content and sets the value. If
            the script that is returned is not valid, the parser status is set
            to fail.
        .PARAMETER RuleType
            The type of rule to get the test script for
    #>
    [void] SetTestScript ($RuleType)
    {
        $thisTestScript = & Get-$($RuleType)TestScript -CheckContent $this.SplitCheckContent

        if (-not $this.SetStatus($thisTestScript))
        {
            $this.set_TestScript($thisTestScript)
        }
    }

    <#
        .SYNOPSIS
            Extracts the set script from the check-content and sets the value
        .DESCRIPTION
            Gets the set script from the xccdf content and sets the value. If
            the script that is returned is not valid, the parser status is set
            to fail.
        .PARAMETER RuleType
            The type of rule to get the set script for
        .PARAMETER FixText
            The set script to run
    #>
    [void] SetSetScript ([string] $RuleType, [string[]] $FixText)
    {
        $checkContent = $this.SplitCheckContent

        $thisSetScript = & Get-$($RuleType)SetScript -FixText $FixText -CheckContent $checkContent

        if (-not $this.SetStatus($thisSetScript))
        {
            $this.set_SetScript($thisSetScript)
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
}