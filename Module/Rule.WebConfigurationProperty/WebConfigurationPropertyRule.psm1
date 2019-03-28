# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\Common\Common.psm1
using module .\..\Rule\Rule.psm1
#header

<#
    .SYNOPSIS
        An Account Policy Rule object
    .DESCRIPTION
        The WebConfigurationPropertyRule class is used to maange the Account Policy Settings.
    .PARAMETER ConfigSection
        The section of the web.config to evaluate
    .PARAMETER Key
        The key in the web.config to evaluate
    .PARAMETER Value
        The value the web.config key should be set to
#>
Class WebConfigurationPropertyRule : Rule
{
    [string] $ConfigSection
    [string] $Key
    [string] $Value <#(ExceptionValue)#>

    WebConfigurationPropertyRule () {}

    WebConfigurationPropertyRule ([xml.xmlelement] $Rule, [bool] $Convert) : Base ($Rule, $Convert) {}

    WebConfigurationPropertyRule ([xml.xmlelement] $Rule) : Base ($Rule)
    {
        $this.ConfigSection = $Rule.ConfigSection
        $this.Key           = $Rule.Key
        $this.Value         = $Rule.Value
    }

    [PSObject] GetExceptionHelp()
    {
        return @{
            Value = "15"
            Notes = $null
        }
    }
}
