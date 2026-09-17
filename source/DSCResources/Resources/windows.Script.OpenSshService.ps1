# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$rules = ($stig.RuleList | Select-Rule -Type ServiceRule).Where({
    $PSItem.DscResource -eq 'Script' -and $PSItem.ServiceName -eq 'sshd'
    })

foreach ($rule in $rules)
{
    $resourceTitle = Get-ResourceTitle -Rule $rule

    Script $resourceTitle
    {
        GetScript =
        {
            $service = Get-CimInstance -ClassName Win32_Service -Filter "Name='sshd'" -ErrorAction SilentlyContinue
            return @{ Result = if ($service) { "$($service.State);$($service.StartMode)" } else { 'NotApplicable' } }
        }

        TestScript =
        {
            $service = Get-CimInstance -ClassName Win32_Service -Filter "Name='sshd'" -ErrorAction SilentlyContinue
            if (-not $service)
            {
                return $true
            }

            return $service.State -eq 'Running' -and $service.StartMode -eq 'Auto'
        }

        SetScript =
        {
            if (Get-Service -Name sshd -ErrorAction SilentlyContinue)
            {
                Set-Service -Name sshd -StartupType Automatic
                Start-Service -Name sshd
            }
        }
    }
}