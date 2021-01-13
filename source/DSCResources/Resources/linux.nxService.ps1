# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$rules = Select-Rule -Type nxServiceRule -RuleList $stig.RuleList

foreach ($rule in $rules)
{
    $ruleEnabled = $null
    [void][bool]::TryParse($rule.Enabled, [ref] $ruleEnabled)

    if ([string]::IsNullOrEmpty($rule.State))
    {
        nxService (Get-ResourceTitle -Rule $rule)
        {
            Name       = $rule.Name
            Enabled    = $ruleEnabled
            Controller = 'systemd'
        }
    }
    else
    {
        nxService (Get-ResourceTitle -Rule $rule)
        {
            Name       = $rule.Name
            Enabled    = $ruleEnabled
            State      = $rule.State
            Controller = 'systemd'
        }
    }
}
