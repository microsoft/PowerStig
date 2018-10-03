# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$rules = Get-RuleClassData -StigData $StigData -Name FileContentRule
#$rules = (Get-RuleClassData -StigData $StigData -Name FileContentRule).Where({ $PSItem.dscresource -eq 'ReplaceText' })

foreach ( $rule in $rules )
{
    if($rule.Key -match "config")
    {
        $Path = $ConfigPath
    }
    else 
    {
        $Path = $PropertiesPath
    }

    KeyValuePairFile "$(Get-ResourceTitle -Rule $rule)"
    {
        Path   = $Path
        Name   = $rule.Key
        Ensure = 'Present'
        Text   = $rule.Value
    }
}
