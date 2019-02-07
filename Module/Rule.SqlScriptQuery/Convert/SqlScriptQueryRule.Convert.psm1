# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\..\Common\Common.psm1
using module .\..\SqlScriptQueryRule.psm1

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
        Convert the contents of an xccdf check-content element into a
        SqlScriptQueryRule object
    .DESCRIPTION
        The SqlScriptQueryRule class is used to extract the SQL Server settings
        from the check-content of the xccdf. Once a STIG rule is identified as a
        SQL script query rule, it is passed to the SqlScriptQueryRule class for
        parsing and validation.
    #>
Class SqlScriptQueryRuleConvert : SqlScriptQueryRule
{
    <#
        .SYNOPSIS
            Default constructor
        .DESCRIPTION
            Converts a xccdf STIG rule element into a SqlScriptQueryRule
        .PARAMETER StigRule
            The STIG rule to convert
    #>
    SqlScriptQueryRuleConvert ([xml.xmlelement] $XccdfRule) : Base ($XccdfRule, $true)
    {
        $ruleType = $this.GetRuleType($this.splitCheckContent)
        $fixText = [SqlScriptQueryRule]::GetFixText($XccdfRule)

        $this.SetGetScript($ruleType)
        $this.SetTestScript($ruleType)
        $this.SetSetScript($ruleType, $fixText)
        $this.SetDscResource()

        if ($this.IsDuplicateRule($global:stigSettings))
        {
            $this.SetDuplicateTitle()
        }
    }

    #region Methods

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
            Extracts the rule type from the check-content and sets the value
        .DESCRIPTION
            Gets the rule type from the xccdf content and sets the value
        .PARAMETER CheckContent
            The rule text from the check-content element in the xccdf
    #>
    [string] GetRuleType ([string[]] $CheckContent)
    {
        $ruleType = Get-SqlRuleType -CheckContent $CheckContent

        return $ruleType
    }

    hidden [void] SetDscResource ()
    {
        $this.DscResource = 'SqlScriptQuery'
    }

    static [bool] Match ([string] $CheckContent)
    {
        # Provide match criteria to validate that the rule is (or is not) a SQL rule.
        # Standard match rules
        if
        (
            $CheckContent -Match "SELECT" -and
            $CheckContent -Match 'existence.*publicly available.*(").*(")\s*(D|d)atabase' -or
            $CheckContent -Match "(DISTINCT|(D|d)istinct)\s+traceid" -or
            $CheckContent -Match "direct access.*server-level" -and
            $CheckContent -NotMatch "SHUTDOWN_ON_ERROR" -and
            $CheckContent -NotMatch "'Alter any availability group' permission"
        )
        {
            return $true
        }
        # SQL Server 2016+ matches
        if
        (
            (
                $CheckContent -Match "(\s|\[)principal_id(\s*|\]\s*)\=\s*1" #SysAdminAccount
            ) -or
            (
                $CheckContent -Match "TRACE_CHANGE_GROUP" -or #V-79239,79291,79293,29295
                $CheckContent -Match "DATABASE_OBJECT_OWNERSHIP_CHANGE_GROUP" -or #V-79259,79261,79263,79265,79275,79277
                $CheckContent -Match "SCHEMA_OBJECT_CHANGE_GROUP" -or #V-79267,79269,79279,79281
                $CheckContent -Match "SUCCESSFUL_LOGIN_GROUP" -or #V-79287,79297
                $CheckContent -Match "FAILED_LOGIN_GROUP" -or #V-79289
                $CheckContent -Match "status_desc = 'STARTED'" #V-79141
            )
        )
        {
            return $true
        }
        return $false
    }

    #endregion
}
