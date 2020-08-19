# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$rules = Select-Rule -Type SharePointSPWebAppGeneralSettingsRule -RuleList $stig.RuleList

$configStringBuilder = New-Object -TypeName System.Text.StringBuilder
[void] $configStringBuilder.AppendLine("SPWebAppGeneralSettings {0}`n{`n`tWebAppUrl = ""$WebAppUrl""") -f $blockTitle

foreach ($rule in $rules)
{
    if ($vulnIDs)
    {
        $vulnIDs += ' ' + $rule.ID
    }
    else
    {
        $vulnIDs = $rule.ID
    }
    $ruleProperty = $rule.PropertyName + " = '" + $rule.PropertyValue +"'"
    [void] $configStringBuilder.AppendLine("`t" + $ruleProperty)
}

[void] $configStringBuilder.AppendLine("`tPsDscRunAsCredential = " + '$SetupAccount')

$blockTitle = "[$($vulnIDs)]"

[void] $configStringBuilder.AppendLine('}')
$scriptblock = [scriptblock]::Create($scriptblockString)
$scriptblock.Invoke()
