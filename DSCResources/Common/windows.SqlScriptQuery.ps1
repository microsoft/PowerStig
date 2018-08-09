#region Header
$rules = Get-RuleClassData -StigData $StigData -Name SqlScriptQueryRule
#endregion Header
#region Resource
foreach ($instance in $ServerInstance)
{
    if ($null -ne $Database)
    {
        foreach ($db in $Database)
        {
            foreach ( $rule in $rules )
            {
                SqlScriptQuery "$(Get-ResourceTitle -Rule $rule)$instance"
                {
                    ServerInstance = $Instance
                    GetQuery       = $rule.GetScript
                    TestQuery      = $rule.TestScript
                    SetQuery       = $rule.SetScript 
                    Variable       = $db
                }
            }
        }
    }
    else 
    {
        foreach ($rule in $rules)
        {
            SqlScriptQuery "$(Get-ResourceTitle -Rule $rule)$instance"
            {
                ServerInstance = $instance
                GetQuery       = $rule.GetScript
                TestQuery      = $rule.TestScript
                SetQuery       = $rule.SetScript 
            }
        }
    }
}
#endregion Resource
