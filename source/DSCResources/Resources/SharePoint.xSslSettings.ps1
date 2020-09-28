# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$rules = Select-Rule -Type SslSettingsRule -RuleList $stig.RuleList

foreach ($rule in $rules)
{
    xSslSettings (Get-ResourceTitle -Rule $rule)
    {
        Name     = $SPAlternateUrlItem["WebAppName"]
        Bindings = (Get-UniqueStringArray -InputObject $rule.Value)
    }
}
