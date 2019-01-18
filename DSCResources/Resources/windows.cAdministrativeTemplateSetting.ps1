# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$rules = Get-RuleClassData -StigData $stigData -Name RegistryRule

foreach ($rule in $rules)
{
    if ($rule.Key -match "^HKEY_CURRENT_USER")
    {
        if ($rule.ValueType -eq 'MultiString')
        {
            $valueData = $rule.ValueData.Split("{;}")
        }
        else
        {
            $valueData = $rule.ValueData
        }

        if( $valueData -eq 'ShouldBeAbsent')
        {
            $rule.Ensure = 'Absent'
        }

        cAdministrativeTemplateSetting (Get-ResourceTitle -Rule $rule)
        {
            PolicyType   = 'User'
            KeyValueName = $rule.Key + '\' + $rule.ValueName
            Data         = $valueData
            Type         = $rule.ValueType
            Ensure       = $rule.Ensure
        }
    }
}
