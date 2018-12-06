# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$rules = Get-RuleClassData -StigData $stigData -Name RegistryRule

foreach ( $rule in $rules )
{
    if ($rule.Key -match "^HKEY_LOCAL_MACHINE")
    {
        If ($rule.ValueType -eq 'MultiString')
        {
            $ValueData = $rule.ValueData.Split("{;}")
        }
        else
        {
            $ValueData = $rule.ValueData
        }

        xRegistry (Get-ResourceTitle -Rule $rule)
        {
            Key       = $rule.Key
            ValueName = $rule.ValueName
            ValueData = $ValueData
            ValueType = $rule.ValueType
            Ensure    = $rule.Ensure
            Force     = $true
        }
    }
}
