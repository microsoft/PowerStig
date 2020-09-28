# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$rules = Select-Rule -Type SPAlternateUrlRule -RuleList $stig.RuleList

foreach ($rule in $rules)
{  
    SPAlternateUrl (Get-ResourceTitle -Rule $rule)
    {
        Url                     = $SPAlternateUrlItem['Url']
        Zone                    = $SPAlternateUrlItem['Zone']
        WebAppName              = $SPAlternateUrlItem['WebAppName']
        Internal                = $SPAlternateUrlItem['Internal']
        Ensure                  = "Present"
        PsDscRunAsCredential    = $SetupAccount
    }
}
