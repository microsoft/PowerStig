# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\Common\Common.psm1
using module .\..\Convert.Stig\Convert.Stig.psm1

$exclude = @($MyInvocation.MyCommand.Name,'Template.*.txt')
$supportFileList = Get-ChildItem -Path $PSScriptRoot -Exclude $exclude
Foreach ($supportFile in $supportFileList)
{
    Write-Verbose "Loading $($supportFile.FullName)"
    . $supportFile.FullName
}
# Header

<#
    .SYNOPSIS

    .DESCRIPTION

    .PARAMETER HostName

    .PARAMETER IpAddress

    .EXAMPLE
#>
Class DnsServerRootHintRule : STIG
{
    [string] $HostName
    [string] $IpAddress

    <#
        .SYNOPSIS
            Default constructor

        .DESCRIPTION
            Converts a xccdf stig rule element into a {0}

        .PARAMETER StigRule
            The STIG rule to convert
    #>
    DnsServerRootHintRule ( [xml.xmlelement] $StigRule )
    {
        $this.InvokeClass( $StigRule )
    }
}
