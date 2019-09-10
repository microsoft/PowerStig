# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$rules = $stig.RuleList | Select-Rule -Type RegistryRule

foreach ($rule in $rules)
{
    if ($rule.ValueType -eq 'MultiString' -and $null -ne $rule.ValueData)
    {
        $valueData = $rule.ValueData.Split("{;}")
    }
    elseif ($null -eq $rule.ValueData)
    {
        # The registry resource's SET will require an empty string array instead of $null
        $valueData = @('')
    }
    else
    {
        $valueData = $rule.ValueData
    }

    if ($valueData -eq 'ShouldBeAbsent')
    {
        $rule.Ensure = 'Absent'
    }

    switch ($rule.dscresource)
    {
        'RegistryPolicyFile'
        {
            if ($rule.key -match 'HKEY_CURRENT_USER')
            {
                $TargetType = 'UserConfiguration'
            }
            else
            {
                $TargetType = 'ComputerConfiguration'
            }

            RegistryPolicyFile (Get-ResourceTitle -Rule $rule)
            {
                Key        = $rule.key -replace 'HKEY_LOCAL_MACHINE\\|HKEY_CURRENT_USER\\'
                TargetType = $TargetType
                ValueName  = $rule.ValueName
                ValueData  = $valueData
                ValueType  = $rule.ValueType
            }
        }

        'Registry'
        {
            if ($rule.Ensure -eq 'Absent')
            {
                Registry (Get-ResourceTitle -Rule $rule)
                {
                    Key       = $rule.Key -replace 'HKEY_LOCAL_MACHINE', 'HKLM:'
                    ValueName = $rule.ValueName
                    Ensure    = $rule.Ensure
                    Force     = $true
                }
            }
            else
            {
                Registry (Get-ResourceTitle -Rule $rule)
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
}
