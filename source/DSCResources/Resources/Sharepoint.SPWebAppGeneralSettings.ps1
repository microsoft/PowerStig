# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$rules = Select-Rule -Type SharePointSPWebAppGeneralSettingsRule -RuleList $stig.RuleList
$rules = $stig.RuleList | Select-Rule -Type 'SharePointSPWebAppGeneralSettingsRule'

$configStringBuilder = New-Object -TypeName System.Text.StringBuilder
$rulePropertyStringBuilder = New-Object -TypeName System.Text.StringBuilder

foreach ($rule in $rules)
{
    $resourceTitle = "`'[$($rules.id -join ' ')]`'"
    [void] $rulePropertyStringBuilder.AppendLine("`t" + $rule.PropertyName + " = '" + $rule.PropertyValue + "'")
}

[void] $configStringBuilder.AppendLine("SPWebAppGeneralSettings $resourceTitle`n{`n`tWebAppUrl = ""$WebAppUrl""")
[void] $configStringBuilder.AppendLine("$rulePropertyStringBuilder" + "`tPsDscRunAsCredential = `$SetupAccount`n}")
$scriptblockString = $configStringBuilder
$scriptblock = [scriptblock]::Create("$scriptblockString")
$scriptblock.Invoke()
