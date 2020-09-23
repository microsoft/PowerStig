# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$rules = Select-Rule -Type SharePointSPAlternateUrlRule -RuleList $stig.RuleList

foreach ($rule in $rules)
{
    [string]$Url = $SPAlternateUrlItem['Url']
    [string]$Zone = $SPAlternateUrlItem['Zone']
    [string]$WebAppName = $SPAlternateUrlItem['WebAppName']
  #  if ($SPAlternateUrlItem['Internal'] -eq "$false") {[bool]$Internal = $false}else{[bool]$Internal = $true}
    
    SPAlternateUrl (Get-ResourceTitle -Rule $rule)
    {
        Url                     = $Url
        Zone                    = $Zone
        WebAppName              = $WebAppName
      #  Internal                = $Internal
        Ensure                  = "Present"
        PsDscRunAsCredential    = $SetupAccount
    }
}
