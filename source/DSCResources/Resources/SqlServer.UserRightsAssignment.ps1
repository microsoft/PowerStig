# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$Rules = $Stig.RuleList | Select-Rule -Type UserRightRule

# Sets variables for Default and Named Instances.
foreach ($instance in $serverInstance)
{
    foreach ($rule in $rules)
    {
        if ($instance -notmatch '\\')
        {
            $instanceName = 'MSSQLSERVER'
            $serverName = $instance
            $identity     = $rule.Identity
        } 
        else
        {
            $instanceName = $instance.Split('{\}')[1]
            $serverName = $instance.Split('{\}')[0]
            $identity     = ("NT SERVICE\MSSQL`$$instanceName")
        }
        UserRightsAssignment (Get-ResourceTitle -Rule $rule)
        {
            Policy   = ($rule.DisplayName -replace " ", "_")
            Identity = $identity
            Force    = $ruleForce
            Ensure   = 'Absent'
        }
    }
}
