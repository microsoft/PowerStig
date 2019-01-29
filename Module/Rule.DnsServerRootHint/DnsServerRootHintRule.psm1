# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\Common\Common.psm1
using module .\..\Rule\Rule.psm1
#header

<#
    .SYNOPSIS
        An Dns Server Root Hint Rule Rule object
    .DESCRIPTION
        The DnsServerRootHintRule class is used to maange the Account Policy Settings.

#>
Class DnsServerRootHintRule : Rule
{
    [string] $HostName
    [string] $IpAddress <#(ExceptionValue)#>

    DnsServerRootHintRule () {}

    DnsServerRootHintRule ([xml.xmlelement] $Rule, [bool] $Convert) : Base ($Rule, $Convert) {}

    DnsServerRootHintRule ([xml.xmlelement] $Rule) : Base ($Rule)
    {
        $this.HostName = $Rule.HostName
        $this.IpAddress = $Rule.IpAddress
    }

    [PSObject] GetExceptionHelp()
    {
        return ([Rule]$this).GetExceptionHelp("{0} = 1")
    }
}
