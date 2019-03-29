# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\Common\Common.psm1
using module .\..\Rule\Rule.psm1
#header

<#
    .SYNOPSIS
        An Account Policy Rule object
    .DESCRIPTION
        The ManualRule class is used to maange the Account Policy Settings.

#>
Class ManualRule : Rule
{
     <#(ExceptionValue)#>

    ManualRule () {}

    ManualRule ([xml.xmlelement] $Rule, [bool] $Convert) : Base ($Rule, $Convert) {}

    ManualRule ([xml.xmlelement] $Rule) : Base ($Rule) {}

    [PSObject] GetExceptionHelp()
    {
        return @{
            Value = "15"
            Notes = $null
        }
    }
}
