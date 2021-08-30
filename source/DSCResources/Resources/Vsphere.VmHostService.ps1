# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$rules = $stig.RuleList | Select-Rule -Type 'VsphereServiceRule'

foreach ($rule in $rules)
{
    $ruleRunning = $null
    [void][bool]::TryParse($rule.Running, [ref] $ruleRunning)

    VmHostService (Get-ResourceTitle -Rule $rule)
    {
        Name       = $HostIP
        Server     = $ServerIP
        Credential = $Credential
        Running    = $ruleRunning
        Key        = $rule.Key
        Policy     = $rule.Policy
    }
}
