# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\Common\Common.psm1
using module .\..\Rule\Rule.psm1
#header

<#
    .SYNOPSIS
        An Account Policy Rule object
    .DESCRIPTION
        The ProcessMitigationRule class is used to maange the Account Policy Settings.
    .PARAMETER MitigationTarget
        The object the mitigation applies to
    .PARAMETER Enable
        A flag to enable the mitigation rule
    .PARAMETER Disable
        A flag to disable the mitigation rule
#>
Class ProcessMitigationRule : Rule
{
    [string] $MitigationTarget
    [string] $Enable
    [string] $Disable <#(ExceptionValue)#>

    ProcessMitigationRule () {}

    ProcessMitigationRule ([xml.xmlelement] $Rule, [bool] $Convert) : Base ($Rule, $Convert) {}

    ProcessMitigationRule ([xml.xmlelement] $Rule) : Base ($Rule)
    {
        $this.MitigationTarget = $Rule.MitigationTarget
        $this.Enable           = $Rule.Enable
        $this.Disable          = $Rule.Disable
    }

    [PSObject] GetExceptionHelp()
    {
        $return = @{
            Value = "15"
            Notes = $null
        }
        return $return
    }
}
