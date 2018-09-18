# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$rules = Get-RuleClassData -StigData $StigData -Name ProcessMitigationRule

foreach ($rule in $rules)
{
    ProcessMitigation (Get-ResourceTitle -Rule $rule)
    {
        MitigationTarget = $rule.MitigationTarget
        Enable           = $rule.Enable
        Disable          = $rule.Disable
    }
}
