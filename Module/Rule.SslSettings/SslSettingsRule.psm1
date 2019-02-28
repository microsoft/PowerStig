# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\Common\Common.psm1
using module .\..\Rule\Rule.psm1
#header

<#
    .SYNOPSIS
        An Ssl Setting Rule object
    .DESCRIPTION
        The SslSettingsRule class is used to maange the IIS Site SSL Settings.

    .PARAMETER Value
        The value the bindings should be set to
#>
Class SslSettingsRule : Rule
{
    [string] $Value <#(ExceptionValue)#>

    SslSettingsRule () {}

    SslSettingsRule ([xml.xmlelement] $Rule, [bool] $Convert) : Base ($Rule, $Convert) {}

    SslSettingsRule ([xml.xmlelement] $Rule) : Base ($Rule)
    {
        $this.Value         = $Rule.Value
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
