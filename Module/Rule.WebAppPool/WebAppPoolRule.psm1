# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\Common\Common.psm1
using module .\..\Rule\Rule.psm1
#header

<#
    .SYNOPSIS
        An Account Policy Rule object
    .DESCRIPTION
        The WebAppPoolRule class is used to maange the Account Policy Settings.
    .PARAMETER Key
        The name of the key in the web.config file
    .PARAMETER Value
        The value the web.config key should be set to
#>
Class WebAppPoolRule : Rule
{
    [string] $Key
    [string] $Value <#(ExceptionValue)#>

    WebAppPoolRule () {}

    WebAppPoolRule ([xml.xmlelement] $Rule, [bool] $Convert) : Base ($Rule, $Convert) {}

    WebAppPoolRule ([xml.xmlelement] $Rule) : Base ($Rule)
    {
        $this.Key = $Rule.Key
        $this.Value = $Rule.Value
    }

    [PSObject] GetExceptionHelp()
    {
        return @{
            Value = "15"
            Notes = $null
        }
    }
}
