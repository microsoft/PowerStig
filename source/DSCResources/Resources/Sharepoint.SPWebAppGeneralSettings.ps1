# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$rules = Select-Rule -Type SharePointSPWebAppGeneralSettingsRule -RuleList $stig.RuleList

# change this variable name to something better
$sb = New-Object -TypeName System.Text.StringBuilder
[void] $sb.AppendLine("SPWebAppGeneralSettings {0}`n{`n`tWebAppUrl = ""$WebAppUrl""")

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
}

$blockTitle = "[$($vulnIDs)]"

[void] $sb.AppendLine('}')
$scriptblockString = $sb.ToString() -f $blockTitle
$scriptblock = [scriptblock]::Create($scriptblockString)
$scriptblock.Invoke()
