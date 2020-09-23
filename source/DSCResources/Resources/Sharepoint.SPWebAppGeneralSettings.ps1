# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$rules = Select-Rule -Type SharePointSPWebAppGeneralSettingsRule -RuleList $stig.RuleList
#$rules = $stig.RuleList | Select-Rule -Type 'SharePointSPWebAppGeneralSettingsRule'

$configStringBuilder = New-Object -TypeName System.Text.StringBuilder
#$rulePropertyStringBuilder = New-Object -TypeName System.Text.StringBuilder

foreach ($rule in $rules)
{
    $resourceTitle = "[$($rules.id -join ' ')]"
  #  [void] $rulePropertyStringBuilder.AppendLine("$($rule.PropertyName) =  $($rule.PropertyValue)")
}

[void] $configStringBuilder.AppendLine("SPWebAppGeneralSettings '$resourceTitle'")
[void] $configStringBuilder.AppendLine("{")
[void] $configStringBuilder.AppendLine("WebAppUrl = '$WebAppUrl'")
foreach ($rule in $rules)
{
 #   $resourceTitle = "[$($rules.id -join ' ')]"
    [void] $configStringBuilder.AppendLine("$($rule.PropertyName) =  '$($rule.PropertyValue)'")
}
[void] $configStringBuilder.AppendLine("PsDscRunAsCredential = `$SetupAccount")
[void] $configStringBuilder.AppendLine("}")
#$scriptblockString = $configStringBuilder.ToString()
[scriptblock]::Create($configStringBuilder.ToString()).Invoke($rules)
#$scriptblock = [scriptblock]::Create($scriptblockString)
#$scriptblock.Invoke()
