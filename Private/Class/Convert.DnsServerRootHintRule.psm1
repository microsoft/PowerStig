#region Header
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\..\Public\Class\Common.Enum.psm1
using module .\..\..\Public\Data\Convert.Data.psm1
# Class module
using module .\..\..\Public\Class\Convert.DnsServerRootHintRule.psm1
#endregion header
#region Main Functions
<#
 .SYNOPSIS
    Converts the STIGObject to a DnsServerRootHintRule
#>
function ConvertTo-DnsServerRootHintRule
{
    [CmdletBinding()]
    [OutputType( [DnsServerRootHintRule] )]
    Param
    (
        [parameter(Mandatory = $true)]
        [xml.xmlelement]
        $StigRule
    )

    Write-Verbose "[$($MyInvocation.MyCommand.Name)]"

    $dnsServerRootHintRule = [DnsServerRootHintRule]::New( $StigRule )

    $dnsServerRootHintRule.SetStigRuleResource()

    $dnsServerRootHintRule.set_HostName( '$null' )

    $dnsServerRootHintRule.set_IpAddress( '$null' )

    return $dnsServerRootHintRule
}
#endregion Main Functions
