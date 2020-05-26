# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$rules = $stig.RuleList | Select-Rule -Type ProcessMitigationRule
$mitigationTargets = $rules.MitigationTarget | Select-Object -Unique

foreach ($target in $mitigationTargets)
{
    $targetrules = $rules | Where-Object {$_.MitigationTarget -eq "$target"}
    $enableValue = @()
    $disableValue = @()
    $idValue = @()

    foreach ($rule in $targetrules)
    {
        if ($rule.enable)
        {
            $enableValue  += $rule.enable
        }
        if ($rule.disable)
        {
            $disableValue += $rule.disable
        }

        $idValue += $rule.id
    }

    if($enableValue.count -gt 1)
    {
        $enableValue = $enableValue.split(',')
    }

    if($disableValue.count -gt 1)
    {
        $disableValue = $disableValue.split(',')
    }

    ProcessMitigation "$Target-$idValue"
    {
        MitigationTarget = $target
        Enable           = $enableValue
        Disable          = $disableValue
    }
}
