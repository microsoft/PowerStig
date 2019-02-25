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
            $key = Get-UniqueString -InputObject $rules.Key
            $value = Get-UniqueStringArray -InputObject $rules.Value -AsString

            $resourceTitle = "[$($rules.id -join ' ')]$website"

            $scriptBlock = [scriptblock]::Create("
                xWebConfigProperty '$resourceTitle'
                {
                    WebsitePath     = 'IIS:\Sites\$website'
                    Filter          = '$rule.ConfigSection'
                    PropertyName    = '$key'
                    Value           = @($value)
                }"
            )
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
        
        $key = Get-UniqueString -InputObject $rules.Key
        $value = Get-UniqueStringArray -InputObject $rules.Value -AsString

        $resourceTitle = "[$($rules.id -join ' ')]$website"

        $scriptBlock = [scriptblock]::Create("
            xWebConfigProperty '$resourceTitle'
            {
                WebsitePath     = '$psPath'
                Filter          = '$rule.ConfigSection'
                PropertyName    = '$key'
                Value           = @($value)
            }"
        )
    }
}
& $scriptBlock
