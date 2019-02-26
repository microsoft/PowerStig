# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
#region Header
$rules = $stig.RuleList | Select-Rule -Type WebConfigurationPropertyRule

if ($WebsiteName)
{
    foreach ($website in $WebsiteName)
    {
        foreach ($rule in $rules)
        {
            if ($rule.Key = 'sslFlags')
            {
                $sslFlagValues += $rule.value
                $value = Get-UniqueStringArray -InputObject $sslFlagValues -asString

                xWebConfigProperty "$(Get-ResourceTitle -Rule $rule -Instance $website)"
                {
                WebsitePath     = "IIS:\Sites\$website"
                Filter          = $rule.ConfigSection
                PropertyName    = $rule.Key
                Value           = $value
                }
            }
            else
            {
                xWebConfigProperty "$(Get-ResourceTitle -Rule $rule -Instance $website)"
                {
                WebsitePath     = "IIS:\Sites\$website"
                Filter          = $rule.ConfigSection
                PropertyName    = $rule.Key
                Value           = $value
                }
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

        xWebConfigProperty "$(Get-ResourceTitle -Rule $rule)"
        {
            WebsitePath     = $psPath
            Filter          = $rule.ConfigSection
            PropertyName    = $rule.Key
            Value           = $rule.Value
        }
    }
}
