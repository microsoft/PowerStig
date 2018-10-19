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
        $StigRule
    )

    Write-Verbose "[$($MyInvocation.MyCommand.Name)]"

    return [DnsServerRootHintRule]::New( $StigRule )
}
#endregion
