# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$rules = Get-RuleClassData -StigData $StigData -Name RegistryRule

foreach ( $rule in $rules )
{
    if ($rule.Key -match "^HKEY_Current_User")
    {
        $valueData = $rule.ValueData.Split("{;}")

        cAdministrativeTemplateSetting (Get-ResourceTitle -Rule $rule)
        {
            PolicyType    = 'User'
            KeyValueName  = $rule.Key + '\' + $rule.ValueName
            Data         = $rule.ValueData
            Type          = $rule.ValueType
        }
    }   
}
