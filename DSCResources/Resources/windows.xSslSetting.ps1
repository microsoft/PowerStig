# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
#region Header
$rules = $stig.RuleList | Select-Rule -Type SslSettingRule

if ($WebsiteName)
{
    foreach ($website in $WebsiteName)
    {
        foreach ($rule in $rules)
        {
            $value = Get-UniqueStringArray -InputObject $rules.Value -AsString

            xSslSettings "$(Get-ResourceTitle -Rule $rule -Instance $website)"
            {
                PSPath          = "IIS:\Sites\$website"
                Filter          = $rule.ConfigSection
                Name            = $rule.Key
                Binding         = $value
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
            PSPath          = $psPath
            Filter          = $rule.ConfigSection
            Name            = $rule.Key
            Binding         = $value
        }
    }
}
