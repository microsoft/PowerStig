# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
#region Functions
<#
 .SYNOPSIS
    Converts the STIGObject to a DnsServerRootHintRule
#>
function ConvertTo-DnsServerRootHintRule
{
    [CmdletBinding()]
    [OutputType([DnsServerRootHintRule])]
    param
    (
        [Parameter(Mandatory = $true)]
        [xml.xmlelement]
        $stigRule
    )

    Write-Verbose "[$($MyInvocation.MyCommand.Name)]"

    $dnsServerRootHintRule = [DnsServerRootHintRule]::New( $stigRule )

    $dnsServerRootHintRule.SetStigRuleResource()

    $dnsServerRootHintRule.set_HostName( '$null' )

    $dnsServerRootHintRule.set_IpAddress( '$null' )

    return $dnsServerRootHintRule
}
#endregion
