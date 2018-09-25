# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$rules = Get-RuleClassData -StigData $StigData -Name RegistryRule

foreach ( $rule in $rules )
{
    if ($rule.Key -match "^HKEY_LOCAL_MACHINE")
    {
        $valueData = $rule.ValueData.Split("{;}")

        xRegistry (Get-ResourceTitle -Rule $rule)
        {
            Key       = $rule.Key
            ValueName = $rule.ValueName
            ValueData = $valueData
            ValueType = $rule.ValueType
            Ensure    = $rule.Ensure
        }
    }
}
