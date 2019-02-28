# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
#region Header
$rules = $stig.RuleList | Select-Rule -Type SslSettingsRule

if ($WebsiteName)
{
    foreach ($website in $WebsiteName)
    {
        foreach ($rule in $rules)
        {
            $value = Get-UniqueStringArray -InputObject $rules.Value -AsString

            xSslSettings "$(Get-ResourceTitle -Rule $rule -Instance $website)"
            {
                Name          = "IIS:\Sites\$website"
                Bindings      = $value
            }
        }
    }
}
else
{
    foreach ($rule in $rules)
    {
        if ($rule.ConfigSection -match '/system.web')
        {
            $psPath = 'MACHINE/WEBROOT'
        }
        else
        {
            $psPath = 'MACHINE/WEBROOT/APPHOST'
        }

        $value = Get-UniqueStringArray -InputObject $rules.Value -AsString

        xSslSettings "$(Get-ResourceTitle -Rule $rule)"
        {
            Name            = $psPath
            Bindings         = $value
        }
    }
}
