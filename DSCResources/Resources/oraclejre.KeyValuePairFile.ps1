# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$rules = Get-RuleClassData -StigData $stigData -Name FileContentRule

foreach ($rule in $rules)
{
    if ($rule.Key -match "config")
    {
        $path = $configPath
    }
    else 
    {
        $path = $propertiesPath
    }

    KeyValuePairFile "$(Get-ResourceTitle -Rule $rule)"
    {
        Path   = $path
        Name   = $rule.Key
        Ensure = 'Present'
        Text   = $rule.Value
    }
}
