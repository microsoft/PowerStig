# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$rules = Select-Rule -Type nxServiceRule -RuleList $stig.RuleList

foreach ($rule in $rules)
{
    nxService (Get-ResourceTitle -Rule $rule)
    {
        Name       = $rule.Name
        Enabled    = $rule.Enabled
        Controller = 'systemd'
    }
}
