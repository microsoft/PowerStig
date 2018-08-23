# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$rules = Get-RuleClassData -StigData $StigData -Name RegistryRule

if ($rules)
{
    foreach ( $rule in $rules )
    {
        $valueData = $rule.ValueData.Split("{;}")

        Registry (Get-ResourceTitle -Rule $rule)
        {
            Key       = $rule.Key
            ValueName = $rule.ValueName
            ValueData = $valueData
            ValueType = $rule.ValueType
            Ensure    = $rule.Ensure
        }
    }
}
