# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\Common\Common.psm1
using module .\..\Rule\Rule.psm1
#header

<#
    .SYNOPSIS
        An Account Policy Rule object
    .DESCRIPTION
        The FileContentRule class is used to maange the Account Policy Settings.
    .PARAMETER Key
        Specifies the name of the key pertaining to a configuration setting
    .PARAMETER Value
        Specifies the value of the configuration setting
#>
Class FileContentRule : Rule
{
    [string] $Key
    [string] $Value <#(ExceptionValue)#>

    FileContentRule () {}

    FileContentRule ([xml.xmlelement] $Rule, [bool] $Convert) : Base ($Rule, $Convert) {}

    FileContentRule ([xml.xmlelement] $Rule) : Base ($Rule)
    {
        $this.Key = $Rule.Key
        $this.Value = $Rule.Value
    }

    [PSObject] GetExceptionHelp()
    {
        return ([Rule]$this).GetExceptionHelp("{0} = 1")
    }
}
