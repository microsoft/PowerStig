# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$rules = ($stig.RuleList | Select-Rule -Type FileContentRule).Where({$PSItem.dscresource -eq 'ReplaceText'})

foreach ($rule in $rules)
{
    xFirefoxPreference (Get-ResourceTitle -Rule $rule)
    {
        InstallDirectory = $InstallDirectory
        PreferenceType   = 'lockPref'
        PreferenceName   = $rule.Key
        PreferenceValue  = $rule.Value
    }
}
