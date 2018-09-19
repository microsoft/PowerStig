# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$rules = Get-RuleClassData -StigData $StigData -Name WebConfigurationPropertyRule

foreach ($website in $WebsiteName)
{
    foreach ( $rule in $rules )
    {
        xWebConfigProperty "$(Get-ResourceTitle -Rule $rule)-$website"
        {
            WebsitePath     = "IIS:\Sites\$website"
            Filter          = $rule.ConfigSection
            PropertyName    = $rule.Key
            Value           = $rule.Value
        }
    }
}
