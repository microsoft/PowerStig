# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

#https://docs.microsoft.com/en-us/aspnet/web-api/overview/security/working-with-ssl-in-web-api

$rules = Select-Rule -Type SslSettingsRule -RuleList $stig.RuleList

$website = $SPAlternateUrlItem["WebAppName"]

foreach ($rule in $rules)
{
    xSslSettings (Get-ResourceTitle -Rule $rule)
    {
        Name     = $website
        Bindings = (Get-UniqueStringArray -InputObject $rule.Value)
    }
}
