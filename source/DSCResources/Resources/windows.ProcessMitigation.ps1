# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$rules = $stig.RuleList | Select-Rule -Type ProcessMitigationRule
$mitigationTargets = $rules.MitigationTarget | Select-Object -Unique

foreach ($target in $mitigationTargets)
{
    $targetRules = $rules | Where-Object {$_.MitigationTarget -eq "$target"}
    $mitigationTypes = $targetRules.MitigationType | Select-Object -Unique

    foreach ($type in $mitigationTypes)
    {
        $typeRules = $targetRules | Where-Object {$_.MitigationType -eq "$type"}
        $mitigationNames = $typeRules.MitigationName | Select-Object -Unique

        foreach ($name in $mitigationNames)
        {
            $nameRules = $typeRules | Where-Object {$_.MitigationName -eq "$name"}

            ProcessMitigation "$target-$type-$name-$nameRules.id"
            {
                MitigationTarget = $target
                MitigationType   = $type
                MitigationName   = $name
                MitigationValue  = $nameRules.MitigationValue
            }
        }
    }
}
