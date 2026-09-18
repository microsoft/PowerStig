# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$rules = $stig.RuleList | Select-Rule -Type DnsServerSettingRule | Where-Object {$_.DscResource -eq 'Script' -and $_.PropertyName -eq 'Mode'}

foreach ($rule in $rules)
{
    Script (Get-ResourceTitle -Rule $rule)
    {
        SetScript =
        {
            Set-DnsServerResponseRateLimiting -Mode Enable
        }

        TestScript =
        {
            if (-not (Get-Command -Name Get-DnsServerResponseRateLimiting -ErrorAction SilentlyContinue))
            {
                return $true
            }

            return (Get-DnsServerResponseRateLimiting).Mode -eq 'Enable'
        }

        GetScript =
        {
            if (-not (Get-Command -Name Get-DnsServerResponseRateLimiting -ErrorAction SilentlyContinue))
            {
                return @{Result = 'NotApplicable'}
            }

            return @{Result = (Get-DnsServerResponseRateLimiting).Mode.ToString()}
        }
    }
}