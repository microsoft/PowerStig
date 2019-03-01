# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
#region Header
$rules = $stig.RuleList | Select-Rule -Type SslSettingsRule

foreach ($website in $WebsiteName)
{
    $value = Get-UniqueStringArray -InputObject $rules.Value -AsString
    [array] $value = $value.Split(',') -replace "'",''

    xSslSettings "$(Get-ResourceTitle -Rule $rule -Instance $website)"
    {
        Name          = "IIS:\Sites\$website"
        Bindings      = $value
    }
}
