# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$rules = Select-Rule -Type SPAlternateUrlRule -RuleList $stig.RuleList

foreach ($rule in $rules)
{  
    if ($SPAlternateUrlItem['Internal'] -like '*true' -or $SPAlternateUrlItem['Internal'] -eq 1)
    {
        [bool] $internal = $true
    }
    else {
        [bool] $internal = $false
    }
    SPAlternateUrl (Get-ResourceTitle -Rule $rule)
    {
        Url                     = $SPAlternateUrlItem['Url']
        Zone                    = $SPAlternateUrlItem['Zone']
        WebAppName              = $SPAlternateUrlItem['WebAppName']
        Internal                = $internal
        Ensure                  = "Present"
        PsDscRunAsCredential    = $SetupAccount
    }
}
