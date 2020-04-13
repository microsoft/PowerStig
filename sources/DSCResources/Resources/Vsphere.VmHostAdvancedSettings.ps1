# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$rules = $stig.RuleList | Select-Rule -Type 'VsphereAdvancedSettingsRule'

$stringBuilder = [System.Text.StringBuilder]::new()
foreach ($rule in $rules)
{
    $null = $stringBuilder.AppendLine("$($rule.AdvancedSetting)")
}


$resourceTitle = "[$($rules.id -join ' ')]"
$scriptBlock = [scriptblock]::Create("
    VmHostAdvancedSettings '$resourceTitle'
    {
        Name = $VsphereHostIP
        Server = $VcenterServerIP
        Credential = $VsphereCredential
        AdvancedSettings = @{
        $($stringBuilder.ToString())
        }
    }"
)

& $scriptBlock
