# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\Common\Common.psm1
using module .\..\Convert.Stig\Convert.Stig.psm1

$exclude = @($MyInvocation.MyCommand.Name,'Template.*.txt')
$supportFileList = Get-ChildItem -Path $PSScriptRoot -Exclude $exclude
Foreach ($supportFile in $supportFileList)
{
    Write-Verbose "Loading $($supportFile.FullName)"
    . $supportFile.FullName
}
# Header

    <#
        .SYNOPSIS

        .DESCRIPTION

        .PARAMETER GetScript

        .PARAMETER TestScript

        .PARAMETER SetScript

        .EXAMPLE
    #>
Class SqlScriptQueryRule : STIG
{
    [string] $GetScript
    [string] $TestScript
    [string] $SetScript

    <#
        .SYNOPSIS
            Default constructor

        .DESCRIPTION
            Converts a xccdf stig rule element into a {0}

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

        .DESCRIPTION

        .PARAMETER RuleType

        .EXAMPLE
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

        .DESCRIPTION

        .PARAMETER RuleType

        .EXAMPLE
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

        .DESCRIPTION

        .PARAMETER RuleType

        .PARAMETER FixText

        .EXAMPLE
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

        .DESCRIPTION

        .PARAMETER CheckContent

        .EXAMPLE
    #>
    [string] GetRuleType ( [string[]] $CheckContent )
    {
        $ruleType = Get-SqlRuleType -CheckContent $CheckContent

        return $ruleType
    }

    #endregion
}
