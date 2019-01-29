# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$rules = $stig.RuleList | Select-Rule -Type WebConfigurationPropertyRule

foreach ($website in $WebsiteName)
{
    foreach ($rule in $rules)
    {
        xWebConfigProperty "$(Get-ResourceTitle -Rule $rule -Instance $website)"
        {
            WebsitePath     = "IIS:\Sites\$website"
            Filter          = $rule.ConfigSection
            PropertyName    = $rule.Key
            Value           = $rule.Value
        }
    }
}
