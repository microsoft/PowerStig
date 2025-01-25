# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$rules = $stig.RuleList | Select-Rule -Type SqlPermissionRule

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
        $permissionArray = @()
        $permissionArray += $rule.Permission.Split("{,}")

        SqlPermission (Get-ResourceTitle -Rule $rule)
        {
            InstanceName = $instanceName
            ServerName   = $serverName
            Credential   = $SQLPermCredential
            Name         = $rule.Name
            Permission = @(
                ServerPermission
                {
                    State      = 'Grant'
                    Permission = $permissionArray
                }
                ServerPermission
                {
                    State      = 'GrantWithGrant'
                    Permission = @()
                }
                ServerPermission
                {
                    State      = 'Deny'
                    Permission = @()
                }
            )
        }
    }
}
