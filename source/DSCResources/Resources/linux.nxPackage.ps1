# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$rules = Select-Rule -Type nxPackageRule -RuleList $stig.RuleList

foreach ($rule in $rules)
{
    nxPackage (Get-ResourceTitle -Rule $rule)
    {
        Name   = $rule.Name
        Ensure = $rule.Ensure
    }
}
