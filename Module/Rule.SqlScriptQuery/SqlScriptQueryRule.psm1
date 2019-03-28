# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\Common\Common.psm1
using module .\..\Rule\Rule.psm1
#header

<#
    .SYNOPSIS
        An Account Policy Rule object
    .DESCRIPTION
        The SqlScriptQueryRule class is used to maange the Account Policy Settings.
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
    [string] $SetScript <#(ExceptionValue)#>

    SqlScriptQueryRule () {}

    SqlScriptQueryRule ([xml.xmlelement] $Rule, [bool] $Convert) : Base ($Rule, $Convert) {}

    SqlScriptQueryRule ([xml.xmlelement] $Rule) : Base ($Rule)
    {
        $this.GetScript = $Rule.GetScript
        $this.TestScript = $Rule.TestScriptv
        $this.SetScript = $Rule.SetScript
    }

    [PSObject] GetExceptionHelp()
    {
        return @{
            Value = "15"
            Notes = $null
        }
    }
}
