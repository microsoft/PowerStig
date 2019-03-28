# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\Common\Common.psm1
using module .\..\Rule\Rule.psm1
#header

<#
    .SYNOPSIS
        An Dns Server Setting Rule object
    .DESCRIPTION
        The DnsServerSettingRule class is used to maange the Dns Server Settings.
    .PARAMETER PropertyName
        The name of the property to configure
    .PARAMETER PropertyValue
        The value to set the proerty to
#>
Class DnsServerSettingRule : Rule
{
    [string] $PropertyName
    [string] $PropertyValue <#(ExceptionValue)#>

    DnsServerSettingRule () { }

    DnsServerSettingRule ([xml.xmlelement] $Rule, [bool] $Convert) : Base ($Rule, $Convert) { }

    DnsServerSettingRule ([xml.xmlelement] $Rule) : Base ($Rule)
    {
        $this.PropertyName = $Rule.PropertyName
        $this.PropertyValue = $Rule.PropertyValue
    }

    [PSObject] GetExceptionHelp()
    {
        return @{
            Value = "15"
            Notes = $null
        }
    }
}
