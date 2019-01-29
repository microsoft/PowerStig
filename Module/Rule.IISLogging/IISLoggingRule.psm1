# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\Common\Common.psm1
using module .\..\Rule\Rule.psm1
#header

<#
    .SYNOPSIS
        An Account Policy Rule object
    .DESCRIPTION
        The IisLoggingRule class is used to maange the Account Policy Settings.
    .PARAMETER LogCustomFieldEntry

    .PARAMETER LogFlags

    .PARAMETER LogFormat

    .PARAMETER LogPeriod

    .PARAMETER LogTargetW3C
#>
Class IisLoggingRule : Rule
{
    [object[]] $LogCustomFieldEntry
    [string] $LogFlags
    [string] $LogFormat
    [string] $LogPeriod
    [string] $LogTargetW3C <#(ExceptionValue)#>

    IisLoggingRule () {}

    IisLoggingRule ([xml.xmlelement] $Rule, [bool] $Convert) : Base ($Rule, $Convert) {}

    IisLoggingRule ([xml.xmlelement] $Rule) : Base ($Rule)
    {
        $this.LogCustomFieldEntry = $Rule.LogCustomFieldEntry
        $this.LogFlags            = $Rule.LogFlags
        $this.LogFormat           = $Rule.LogFormat
        $this.LogPeriod           = $Rule.LogPeriod
        $this.LogTargetW3C        = $Rule.LogTargetW3C
    }

    [PSObject] GetExceptionHelp()
    {
        return ([Rule]$this).GetExceptionHelp("{0} = 1")
    }
}
