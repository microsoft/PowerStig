# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$rules = Get-RuleClassData -StigData $StigData -Name ProcessMitigationRule

Foreach ( $rule in $rules )
{
    ProcessMitigation (Get-ResourceTitle -Rule $rule)
    {
        Enable              = $rule.Enable
        MitigationTarget    = $rule.MitigationTarget
    }
}
