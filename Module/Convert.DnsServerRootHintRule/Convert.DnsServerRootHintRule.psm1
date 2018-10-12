# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\Common\Common.psm1
using module .\..\Rule\Rule.psm1

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
        Convert the contents of an xccdf check-content element into an Dns Server
        Root Hint object
    .DESCRIPTION
        The DnsServerRootHintRule class is used to extract the Dns Server Root Hints
        from the check-content of the xccdf. Once a STIG rule is identified as a
        DnsServerRootHint, it is passed to the DnsServerRootHintRule class for
        parsing and validation.
    .PARAMETER HostName
        The host name of the root hint server
    .PARAMETER IpAddress
        The ip address of the root hint server
#>
Class DnsServerRootHintRule : Rule
{
    [string] $HostName
    [string] $IpAddress

    <#
        .SYNOPSIS
            Default constructor
        .DESCRIPTION
            Converts a xccdf stig rule element into a DnsServerRootHintRule
        .PARAMETER StigRule
            The STIG rule to convert
    #>
    DnsServerRootHintRule ( [xml.xmlelement] $StigRule )
    {
        $this.InvokeClass( $StigRule )
        $this.set_HostName( '$null' )
        $this.set_IpAddress( '$null' )
        $this.SetDscResource()
    }

    hidden [void] SetDscResource ()
    {
        $this.DscResource = 'Script'
    }
}
