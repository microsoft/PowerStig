# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\Common\Common.psm1
using module .\..\Rule\Rule.psm1

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
    .PARAMETER GetScript
        The Get script content
    .PARAMETER TestScript
        The test script content
    .PARAMETER SetScript
        The set script content
    #>
Class SqlScriptQueryRule : Rule
{
    [string] $GetScript
    [string] $TestScript
    [string] $SetScript

    <#
        .SYNOPSIS
            Default constructor
        .DESCRIPTION
            Converts a xccdf STIG rule element into a SqlScriptQueryRule
        .PARAMETER StigRule
            The STIG rule to convert
    #>
    SqlScriptQueryRule ( [xml.xmlelement] $StigRule )
    {
        $this.InvokeClass( $StigRule )
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
    [void] SetGetScript ( [string] $RuleType )
    {
        $thisGetScript = & Get-$($RuleType)GetScript -CheckContent $this.SplitCheckContent

        if ( -not $this.SetStatus( $thisGetScript ) )
        {
            $this.set_GetScript( $thisGetScript )
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
    [void] SetTestScript ( $RuleType )
    {
        $thisTestScript = & Get-$($RuleType)TestScript -CheckContent $this.SplitCheckContent

        if ( -not $this.SetStatus( $thisTestScript ) )
        {
            $this.set_TestScript( $thisTestScript )
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
    [void] SetSetScript ( [string] $RuleType, [string[]] $FixText )
    {
        $checkContent = $this.SplitCheckContent

        $thisSetScript = & Get-$($RuleType)SetScript -FixText $FixText -CheckContent $checkContent

        if ( -not $this.SetStatus( $thisSetScript ) )
        {
            $this.set_SetScript( $thisSetScript )
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
    [string] GetRuleType ( [string[]] $CheckContent )
    {
        $ruleType = Get-SqlRuleType -CheckContent $CheckContent

        return $ruleType
    }

    #endregion
}
