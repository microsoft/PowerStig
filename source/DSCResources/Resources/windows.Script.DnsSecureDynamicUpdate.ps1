# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$rules = $stig.RuleList | Select-Rule -Type DnsServerSettingRule | Where-Object {$_.DscResource -eq 'Script' -and $_.PropertyName -eq 'DynamicUpdate'}

foreach ($rule in $rules)
{
    Script (Get-ResourceTitle -Rule $rule)
    {
        SetScript =
        {
            Get-DnsServerZone |
                Where-Object {$_.ZoneType -eq 'Primary' -and $_.IsDsIntegrated -and $_.DynamicUpdate -ne 'Secure'} |
                ForEach-Object {Set-DnsServerPrimaryZone -Name $_.ZoneName -DynamicUpdate Secure}
        }

        TestScript =
        {
            if (-not (Get-Command -Name Get-DnsServerZone -ErrorAction SilentlyContinue))
            {
                return $true
            }

            $noncompliantZones = Get-DnsServerZone |
                Where-Object {$_.ZoneType -eq 'Primary' -and $_.IsDsIntegrated -and $_.DynamicUpdate -ne 'Secure'}

            return @($noncompliantZones).Count -eq 0
        }

        GetScript =
        {
            if (-not (Get-Command -Name Get-DnsServerZone -ErrorAction SilentlyContinue))
            {
                return @{Result = 'NotApplicable'}
            }

            $zoneStates = Get-DnsServerZone |
                Where-Object {$_.ZoneType -eq 'Primary' -and $_.IsDsIntegrated} |
                ForEach-Object {"$($_.ZoneName)=$($_.DynamicUpdate)"}

            return @{Result = ($zoneStates -join ';')}
        }
    }
}