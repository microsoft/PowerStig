# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$rules = Select-Rule -Type nxFileLineRule -RuleList $stig.RuleList

foreach ($rule in $rules)
{
    nxFileLine (Get-ResourceTitle -Rule $rule)
    {
        FilePath              = $rule.FilePath
        ContainsLine          = $rule.ContainsLine
        DoesNotContainPattern = $rule.DoesNotContainPattern
    }
}
