# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\Common\Common.psm1
using module .\..\Rule\Rule.psm1
#header

<#
    .SYNOPSIS
        SQL Server configuration option rule
    .DESCRIPTION
        The SqlServerConfigurationRule class is used to maange the Account Policy Settings.
    .PARAMETER OptionName
        The SQL Server configuration option name
    .PARAMETER OptionValue
        The SQL Server configuration option value
    .PARAMETER Ensure
        The ensure property
#>
class SqlServerConfigurationRule : Rule
{
    [string] $OptionName
    [string] $OptionValue <#(ExceptionValue)#>
    [string] $Ensure

    <#
        .SYNOPSIS
            Default constructor to support the AsRule cast method
    #>
    SqlServerConfigurationRule ()
    {
    }

    <#
        .SYNOPSIS
            Used to load PowerSTIG data from the processed data directory
        .PARAMETER Rule
            The STIG rule to load
    #>
    SqlServerConfigurationRule ([xml.xmlelement] $Rule) : base ($Rule)
    {
    }

    <#
        .SYNOPSIS
            The Convert child class constructor
        .PARAMETER Rule
            The STIG rule to convert
        .PARAMETER Convert
            A simple bool flag to create a unique constructor signature
    #>
    SqlServerConfigurationRule ([xml.xmlelement] $rule, [switch] $convert) : base ($rule, $convert)
    {
    }

    <#
        .SYNOPSIS
            Creates class specifc help content
    #>
    [PSObject] GetExceptionHelp()
    {
        return @{
            Value = "15"
            Notes = "Allowed values are per specific SQL Server Configuration setting. Refer to SQL Server documentation for allowed values."
        }
    }
}
