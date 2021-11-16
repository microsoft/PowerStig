# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\Common\Common.psm1
using module .\..\Rule\Rule.psm1
#header

<#
    .SYNOPSIS
        SQL Server login rule
    .DESCRIPTION
        The SqlLoginRule class is used to manage SQL authentication logins
    .PARAMETER Name
        The SQL Server login name
    .PARAMETER LoginType
        The SQL Server login type
    .PARAMETER LoginPasswordPolicyEnforced
        The SQL Server login password complexity option
    .PARAMETER LoginPasswordExpirationEnabled
        The SQL Server login password expiration option
    .PARAMETER Ensure
        The ensure property
#>
class SqlLoginRule : Rule
{
    [string] $Name
    [string] $LoginType
    [string] $LoginPasswordPolicyEnforced <#(ExceptionValue)#>
    [string] $LoginPasswordExpirationEnabled
    [string] $LoginMustChangePassword
    [string] $Ensure
    [string] $OrganizationValueTestString

    <#
        .SYNOPSIS
            Default constructor to support the AsRule cast method
    #>
    SqlLoginRule ()
    {
    }

    <#
        .SYNOPSIS
            Used to load PowerSTIG data from the processed data directory
        .PARAMETER Rule
            The STIG rule to load
    #>
    SqlLoginRule ([xml.xmlelement] $Rule) : base ($Rule)
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
    SqlLoginRule ([xml.xmlelement] $Rule, [switch] $Convert) : base ($Rule, $Convert)
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
            Notes = $null
        }
    }
}
