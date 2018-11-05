# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$ruleList = Get-RuleClassData -StigData $stigData -Name ProcessMitigationRule

foreach ($rule in $ruleList)
{
    $duplicateTargetList = $ruleList | Where-Object {$_.MitigationTarget -eq $rule.MitigationTarget}
    $ruleEnableValue = @()
    $disableValue = @()

    foreach ($duplicateTarget in $duplicateTargetList)
    {
        if ($duplicateTarget.enable)
        {
            $ruleEnableValue += $duplicateTarget.enable
        }
        if ($duplicateTarget.disable)
        {
            $ruleDisableValue += $duplicateTarget.disable
        }
    }

    ProcessMitigation (Get-ResourceTitle -Rule $rule)
    {
        MitigationTarget = $rule.MitigationTarget
        Enable           = ($ruleEnableValue -join ",")
        Disable          = ($ruleDisableValue -join ",")
    }
}
