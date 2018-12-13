# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$rules = Get-RuleClassData -StigData $stigData -Name RegistryRule

foreach ( $rule in $rules )
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
