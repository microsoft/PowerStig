#region Header
$rules = Get-RuleClassData -StigData $StigData -Name WebConfigurationPropertyRule
#endregion Header
#region Resource
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
#endregion Resource
