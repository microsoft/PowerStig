# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$rules = $stig.RuleList | Select-Rule -Type SqlDatabaseRule

# Sets variables for Default and Named Instances.
foreach ($instance in $serverInstance)
{
    if ($instance -notmatch '\\')
    {
        $instanceName = 'MSSQLSERVER'
        $serverName = $instance
    } 
    else
    {
        $instanceName = $instance.Split('{\}')[1]
        $serverName = $instance.Split('{\}')[0]
    }

    foreach ($rule in $rules)
    {
        SqlDatabase (Get-ResourceTitle -Rule $rule)
        {
            InstanceName = $instanceName
            ServerName   = $serverName
            Name         = $rule.Name
            Ensure       = $rule.Ensure
        }
    }
}
