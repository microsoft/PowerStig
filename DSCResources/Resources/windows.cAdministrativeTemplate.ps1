# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$rules = Get-RuleClassData -StigData $StigData -Name RegistryRule #jjs

Foreach ( $rule in $rules )
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
else 
{
    Foreach ( $rule in $rules )
    {
        $valueData = $rule.ValueData.Split("{;}")
    
        cAdministrativeTemplate (Get-ResourceTitle -Rule $rule)
        {
            Key       = $rule.Key
            ValueName = $rule.ValueName
            ValueData = $valueData
            ValueType = $rule.ValueType
            Ensure    = $rule.Ensure
        }
    }
}
