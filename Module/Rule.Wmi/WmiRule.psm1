# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\Common\Common.psm1
using module .\..\Rule\Rule.psm1
#header

<#
    .SYNOPSIS
        An Wmi Rule object
    .DESCRIPTION
        The WmiRule class is used to maange the Wmi settings.
    .PARAMETER Query
        The WMI class query
    .PARAMETER Property
        The class property
    .PARAMETER Value
        The value the property should be set to
    .PARAMETER Operator
        The PowerShell equivalent operator

#>
Class WmiRule : Rule
{
    [string] $Query
    [string] $Property
    [string] $Value
    [string] $Operator <#(ExceptionValue)#>

    WmiRule () {}

    WmiRule ([xml.xmlelement] $Rule, [bool] $Convert) : Base ($Rule, $Convert) {}

    WmiRule ([xml.xmlelement] $Rule) : Base ($Rule)
    {
        $this.Query      = $Rule.Query
        $this.Property   = $Rule.Property
        $this.Value      = $Rule.Value
        $this.Operator   = $Rule.Operator
    }

    [PSObject] GetExceptionHelp()
    {
        return @{
            Value = "15"
            Notes = $null
        }
    }
}
