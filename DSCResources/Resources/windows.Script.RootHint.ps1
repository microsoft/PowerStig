# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$rules = Get-RuleClassData -StigData $StigData -Name DnsServerRootHintRule

Foreach ( $rule in $rules )
{
    Script (Get-ResourceTitle -Rule $rule)
    {
        SetScript =
        {
            Get-DnsServerRootHint | Where-Object {$_.NameServer.RecordData.NameServer -like "*.Root-Servers.net."} | Remove-DnsServerRootHint
        }

        TestScript =
        {
            $result = $false
            $targetResource = Get-DnsServerRootHint | Where-Object {$_.NameServer.RecordData.NameServer -like "*.Root-Servers.net."}
            if ($targetResource.Count -eq 0) {
                $result = $True
            }

            Return $result
        }

        GetScript =
        {
            $returnString = $null
            Foreach ( $rootHint in (Get-DnsServerRootHint) ) {
                $returnString += $rootHint.ipaddress.hostName + ";"
            }

            Return  @{ Result = $returnString }
        }
    }
}
