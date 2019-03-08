# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$rules = $stig.RuleList | Select-Rule -Type RegistryRule

foreach ($rule in $rules)
{
    if ($rule.Key -match "^HKEY_LOCAL_MACHINE")
    {
        if ($rule.ValueType -eq 'MultiString')
        {
            $valueData = $rule.ValueData.Split("{;}")
        }
        else
        {
            $valueData = $rule.ValueData
        }

        if ($valueData -eq 'ShouldBeAbsent')
        {
            $rule.Ensure = 'Absent'
        }

        if ($rule.Ensure -eq 'Absent')
        {
            #Changing our key to adhere to the resource requirements. Issue discussed at this link https://github.com/PowerShell/xPSDesiredStateConfiguration/issues/444
            $rule.Key = $rule.Key -replace 'HKEY_LOCAL_MACHINE', 'HKLM:'
            xRegistry (Get-ResourceTitle -Rule $rule)
            {
                Key       = $rule.Key
                ValueName = $rule.ValueName
                Ensure    = $rule.Ensure
                Force     = $true
            }
        }
        else
        {
            xRegistry (Get-ResourceTitle -Rule $rule)
            {
                Key       = $rule.Key
                ValueName = $rule.ValueName
                ValueData = $valueData
                ValueType = $rule.ValueType
                Ensure    = $rule.Ensure
                Force     = $true
            }
        }
    }
}
