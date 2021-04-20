# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$Rules = $Stig.RuleList | Select-Rule -Type SqlServerDSCRule

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
        SqlServerConfiguration (Get-ResourceTitle -Rule $rule)
        {
            InstanceName = $instanceName
            ServerName = $serverName
            OptionName = $rule.OptionName
            OptionValue = $rule.OptionValue
        }
    }
}
