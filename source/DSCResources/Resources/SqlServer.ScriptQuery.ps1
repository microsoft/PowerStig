# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$rules = $stig.RuleList | Select-Rule -Type SqlScriptQueryRule

foreach ($instance in $ServerInstance)
{
    if ($instance -notmatch '\\')
    {
        $instanceName = 'MSSQLSERVER'
        $serverName   = $instance
    } 
    else
    {
        $instanceName = $instance.Split('{\}')[1]
        $serverName   = $instance.Split('{\}')[0]
    }

    if ($null -ne $Database)
    {
        foreach ($db in $Database)
        {
            $getScript = '{0} --{1}' -f $rule.GetScript, $db

            foreach ($rule in $rules)
            {
                $resourceTitle = '{0}{1}_{2}' -f (Get-ResourceTitle -Rule $rule), $instanceName, $db
                SqlScriptQuery "$resourceTitle"
                {
                    ServerName     = $serverName
                    InstanceName   = $instanceName
                    GetQuery       = $getScript
                    TestQuery      = $rule.TestScript
                    SetQuery       = $rule.SetScript
                    Variable       = Format-SqlScriptVariable -Database $db -Variable $($rule.Variable) -VariableValue $($rule.VariableValue)
                }
            }
        }
    }
    else
    {
        foreach ($rule in $rules)
        {
            if ($null -ne $rule.Variable -and $null -ne $rule.VariableValue)
            {
                SqlScriptQuery "$(Get-ResourceTitle -Rule $rule)$instanceName"
                {
                    ServerName     = $serverName
                    InstanceName   = $instanceName
                    GetQuery       = $rule.GetScript
                    TestQuery      = $rule.TestScript
                    SetQuery       = $rule.SetScript
                    Variable       = Format-SqlScriptVariable -Variable $($rule.Variable) -VariableValue $($rule.VariableValue)
                }
                continue
            }

            SqlScriptQuery "$(Get-ResourceTitle -Rule $rule)$instanceName"
            {
                ServerName     = $serverName
                InstanceName   = $instanceName
                GetQuery       = $rule.GetScript
                TestQuery      = $rule.TestScript
                SetQuery       = $rule.SetScript
            }
        }
    }
}
