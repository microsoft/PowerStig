# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$rules = Select-Rule -Type SPWebAppGeneralSettingsRule -RuleList $stig.RuleList

$configStringBuilder = New-Object -TypeName System.Text.StringBuilder

foreach ($rule in $rules)
{
    $resourceTitle = "[$($rules.id -join ' ')]"
}

[void] $configStringBuilder.AppendLine("SPWebAppGeneralSettings '$resourceTitle'")
[void] $configStringBuilder.AppendLine("{")
[void] $configStringBuilder.AppendLine("WebAppUrl = '$WebAppUrl'")
foreach ($rule in $rules)
{
    if($rule.PropertyValue -eq 'true' -or $rule.PropertyValue -eq 'False')
    {
        $correctedString = "`$$($rule.PropertyValue)"  
        [void] $configStringBuilder.AppendLine("$($rule.PropertyName) =  $correctedString")
    }else 
    {
        [void] $configStringBuilder.AppendLine("$($rule.PropertyName) =  '$($rule.PropertyValue)'")
    }
}

[void] $configStringBuilder.AppendLine("PsDscRunAsCredential = `$SetupAccount")
[void] $configStringBuilder.AppendLine("}")
[scriptblock]::Create($configStringBuilder.ToString()).Invoke($rules)
