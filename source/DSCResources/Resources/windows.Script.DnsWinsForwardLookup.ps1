# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$rules = $stig.RuleList | Select-Rule -Type DnsServerSettingRule | Where-Object {$_.DscResource -eq 'Script' -and $_.PropertyName -eq 'WinsForwardLookup'}

foreach ($rule in $rules)
{
    Script (Get-ResourceTitle -Rule $rule)
    {
        SetScript =
        {
            Get-DnsServerZone |
                Where-Object {$_.ZoneType -eq 'Primary' -and -not $_.IsReverseLookupZone} |
                ForEach-Object {
                    $zoneName = $_.ZoneName
                    Get-DnsServerResourceRecord -ZoneName $zoneName -RRType WINS -ErrorAction SilentlyContinue |
                        Remove-DnsServerResourceRecord -ZoneName $zoneName -Force
                }
        }

        TestScript =
        {
            if (-not (Get-Command -Name Get-DnsServerZone -ErrorAction SilentlyContinue))
            {
                return $true
            }

            $winsRecords = Get-DnsServerZone |
                Where-Object {$_.ZoneType -eq 'Primary' -and -not $_.IsReverseLookupZone} |
                ForEach-Object {Get-DnsServerResourceRecord -ZoneName $_.ZoneName -RRType WINS -ErrorAction SilentlyContinue}

            return @($winsRecords).Count -eq 0
        }

        GetScript =
        {
            if (-not (Get-Command -Name Get-DnsServerZone -ErrorAction SilentlyContinue))
            {
                return @{Result = 'NotApplicable'}
            }

            $zonesWithWins = Get-DnsServerZone |
                Where-Object {$_.ZoneType -eq 'Primary' -and -not $_.IsReverseLookupZone} |
                Where-Object {
                    @(Get-DnsServerResourceRecord -ZoneName $_.ZoneName -RRType WINS -ErrorAction SilentlyContinue).Count -gt 0
                } |
                Select-Object -ExpandProperty ZoneName

            return @{Result = ($zonesWithWins -join ';')}
        }
    }
}