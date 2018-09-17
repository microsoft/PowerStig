#region Header
$rules = Get-RuleClassData -StigData $StigData -Name MimeTypeRule
#endregion Header
#region Resource
foreach ($website in $WebsiteName)
{
    foreach ($rule in $rules)
    {
        xIisMimeTypeMapping "$(Get-ResourceTitle -Rule $rule)-$website"
        {
            ConfigurationPath = "IIS:\Sites\$website"
            Extension         = $rule.Extension
            MimeType          = $rule.MimeType
            Ensure            = $rule.Ensure
        }
    }
}
#endregion Resource
