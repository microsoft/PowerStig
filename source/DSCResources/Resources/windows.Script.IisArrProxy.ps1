# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$rules = $stig.RuleList | Select-Rule -Type WebConfigurationPropertyRule | Where-Object {
    $_.DscResource -eq 'Script' -and $_.ConfigSection -eq '/system.webServer/proxy'
}

foreach ($rule in $rules)
{
    Script (Get-ResourceTitle -Rule $rule)
    {
        SetScript =
        {
            try
            {
                $null = Get-WebConfigurationProperty -PSPath 'MACHINE/WEBROOT/APPHOST' -Filter 'system.webServer/proxy' -Name 'enabled' -ErrorAction Stop
            }
            catch
            {
                return
            }

            Set-WebConfigurationProperty -PSPath 'MACHINE/WEBROOT/APPHOST' -Filter 'system.webServer/proxy' -Name 'enabled' -Value $false
        }

        TestScript =
        {
            try
            {
                $proxyEnabled = Get-WebConfigurationProperty -PSPath 'MACHINE/WEBROOT/APPHOST' -Filter 'system.webServer/proxy' -Name 'enabled' -ErrorAction Stop
            }
            catch
            {
                return $true
            }

            return -not [System.Convert]::ToBoolean($proxyEnabled.Value)
        }

        GetScript =
        {
            try
            {
                $proxyEnabled = Get-WebConfigurationProperty -PSPath 'MACHINE/WEBROOT/APPHOST' -Filter 'system.webServer/proxy' -Name 'enabled' -ErrorAction Stop
            }
            catch
            {
                return @{Result = 'NotApplicable'}
            }

            return @{Result = $proxyEnabled.Value.ToString()}
        }
    }
}