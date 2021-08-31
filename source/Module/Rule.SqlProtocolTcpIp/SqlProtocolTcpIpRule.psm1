# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\Common\Common.psm1
using module .\..\Rule\Rule.psm1
#header

<#
    .SYNOPSIS
        SQL Server protocol rule
    .DESCRIPTION
        The SqlProtocolTcpIpRule class is TCPIP properties
    .PARAMETER TcpPort
        The SQL Server TcpPort
#>
class SqlProtocolTcpIpRule : Rule
{
    [string] $TcpPort <#(ExceptionValue)#>

    <#
        .SYNOPSIS
            Default constructor to support the AsRule cast method
    #>
    SqlProtocolTcpIpRule ()
    {
    }

    <#
        .SYNOPSIS
            Used to load PowerSTIG data from the processed data directory
        .PARAMETER Rule
            The STIG rule to load
    #>
    SqlProtocolTcpIpRule ([xml.xmlelement] $Rule) : base ($Rule)
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
    SqlProtocolTcpIpRule ([xml.xmlelement] $Rule, [switch] $Convert) : base ($Rule, $Convert)
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
