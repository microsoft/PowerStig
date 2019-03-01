# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\Common\Common.psm1
using module .\..\Rule\Rule.psm1
# Header

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

    <#
        .SYNOPSIS
        Default constructor to support the AsRule cast method
    #>
    SslSettingsRule () {}

    <#
        .SYNOPSIS
        The Convert child class constructor
        .PARAMETER Rule
        The STIG rule to convert
        .PARAMETER Convert
        A simple bool flag to create a unique constructor signature
    #>
    SslSettingsRule ([xml.xmlelement] $Rule, [bool] $Convert) : Base ($Rule, $Convert) {}

    <#
        .SYNOPSIS
        Used to load PowerSTIG data from the processed data directory
        .PARAMETER Rule
        The STIG rule to load
    #>
    SslSettingsRule ([xml.xmlelement] $Rule) : Base ($Rule)
    {
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
