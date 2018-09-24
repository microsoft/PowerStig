# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$rules = Get-RuleClassData -StigData $StigData -Name ProcessMitigationRule

if ($rules.MitigationTarget -match 'System')
{
    foreach ($rule in $rules)
    {
        $enable = $rule.Enable
        $enableValue = @()
        $enableValue += "$enable"
    }

    ProcessMitigation (Get-ResourceTitle -Rule $rule)
    {
        MitigationTarget = $rule.MitigationTarget
        Enable           = $rule.$enableValue
        Disable          = $rule.Disable
    }
}
else
{
    foreach ($rule in $rules)
    {
        ProcessMitigation (Get-ResourceTitle -Rule $rule)
        {
            MitigationTarget = $rule.MitigationTarget
            Enable           = $rule.Enable
            Disable          = $rule.Disable
        }
    }    
}
