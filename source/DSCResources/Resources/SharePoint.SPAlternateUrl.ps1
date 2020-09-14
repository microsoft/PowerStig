# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$rules = Select-Rule -Type SharePointSPAlternateUrlRule -RuleList $stig.RuleList

foreach ($rule in $rules)
{
    SPAlternateUrl (Get-ResourceTitle -Rule $rule)
    {
        ForEach ($Key in $SPALternateUrlItem.Keys)
        {
            "$Key = $($SPAlternativeUrlItem[$key])"
        }
        PsDscRunAsCredential = $SetupAccount
    }
}