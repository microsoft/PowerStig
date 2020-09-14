# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

#https://docs.microsoft.com/en-us/aspnet/web-api/overview/security/working-with-ssl-in-web-api

$rules = $stig.RuleList | Select-Rule -Type SslSettingsRule

$website = $SPAlternateUrlItem["WebAppName"]

if ($rules)
{
    foreach ($website in $WebsiteName)
    {
        xSslSettings "[$($rules.id -join ' ')]$website"
        {
            Name     = $website
            Bindings = (Get-UniqueStringArray -InputObject $rules.Value)
        }
    }
}
