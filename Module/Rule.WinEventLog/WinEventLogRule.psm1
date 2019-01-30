# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\Common\Common.psm1
using module .\..\Rule\Rule.psm1
#header

<#
    .SYNOPSIS
        An Account Policy Rule object
    .DESCRIPTION
        The WinEventLogRule class is used to maange the Account Policy Settings.
    .PARAMETER LogName
        The name of the log
    .PARAMETER IsEnabled
        The enabled status of the log
#>
Class WinEventLogRule : Rule
{
    [string] $LogName
    [bool] $IsEnabled <#(ExceptionValue)#>

    WinEventLogRule () {}

    WinEventLogRule ([xml.xmlelement] $Rule, [bool] $Convert) : Base ($Rule, $Convert) {}

    WinEventLogRule ([xml.xmlelement] $Rule) : Base ($Rule)
    {
        $this.LogName = $Rule.LogName
        $this.IsEnabled = $Rule.IsEnabled
    }

    [PSObject] GetExceptionHelp()
    {
        return ([Rule]$this).GetExceptionHelp("{0} = 1")
    }
}
