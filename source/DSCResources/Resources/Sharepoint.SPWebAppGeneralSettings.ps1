# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$rules = Select-Rule -Type SharePointSPWebAppGeneralSettingsRule -RuleList $stig.RuleList

$configStringBuilder = New-Object -TypeName System.Text.StringBuilder
$rulePropertyStringBuilder = New-Object -TypeName System.Text.StringBuilder

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
    [void] $rulePropertyStringBuilder.AppendLine("`t" + $rule.PropertyName + " = '" + $rule.PropertyValue + "'")
}

$blockTitle = "[$($vulnIDs)]"
[void] $configStringBuilder.AppendLine("SPWebAppGeneralSettings $blockTitle`n{`n`tWebAppUrl = ""$WebAppUrl""")
[void] $configStringBuilder.AppendLine($rulePropertyStringBuilder)
[void] $configStringBuilder.AppendLine("`tPsDscRunAsCredential = `$SetupAccount")
[void] $configStringBuilder.AppendLine('}')
$scriptblockString = $configStringBuilder
$scriptblock = [scriptblock]::Create($scriptblockString)
$scriptblock.Invoke()
