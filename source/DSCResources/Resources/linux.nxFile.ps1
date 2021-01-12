# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$rules = Select-Rule -Type nxFileRule -RuleList $stig.RuleList

foreach ($rule in $rules)
{
    nxFileLine (Get-ResourceTitle -Rule $rule)
    {
        FilePath = $rule.FilePath
        Contents = $rule.Contents
    }
}
