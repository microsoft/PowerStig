# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$rules = $stig.RuleList | Select-Rule -Type SharePoint.SPSiteRule

foreach ($rule in $rules)
{
    SPSite (Get-ResourceTitle -Rule $rule)
    {
        Url = $rule.Url
        OwnerAlias = $rule.OwnerAlias
        ContentDatabase = $rule.ContentDatabase
        HostHeaderWebApplication = $rule.HostHeaderWebApplication
        Name = $rule.Name
        OwnerEmail = $rule.OwnerEmail
    }
}