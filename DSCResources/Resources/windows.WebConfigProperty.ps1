#region Header
$rules = Get-RuleClassData -StigData $StigData -Name WebConfigurationPropertyRule
#endregion Header
#region Resource
if ($WebsiteName)
{
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
}
else
{
    foreach ( $rule in $rules )
    {
        xWebConfigProperty "$(Get-ResourceTitle -Rule $rule)"
        {
            WebsitePath     = "MACHINE/WEBROOT/APPHOST"
            Filter          = $rule.ConfigSection
            PropertyName    = $rule.Key
            Value           = $rule.Value
        }
    }
}
#endregion Resource
