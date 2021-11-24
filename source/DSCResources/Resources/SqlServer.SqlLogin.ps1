# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$rules = $stig.RuleList | Select-Rule -Type SqlLoginRule

# Creates variable with SQL Server Instance Name.
foreach ($instance in $serverInstance)
{
    if ($instance -notmatch '\\')
    {
        $instanceName      = 'MSSQLSERVER'
        $serverName        = $instance
        $sqlConnectionName = $hostName
    }
        else
        {
            $instanceName      = $instance.Split('{\}')[1]
            $serverName        = $instance.Split('{\}')[0]
            $sqlConnectionName = $instance
        }

    foreach ($rule in $rules)
    {
        # Organizational setting for multiple Sql logins should be comma delimited.
        $loginNameSplit = $rules.Name.Split("{,}")

        foreach ($login in $loginNameSplit)
        {
            $rulePasswordPolicy = $null
            [void][bool]::TryParse($rule.LoginPasswordPolicyEnforced, [ref]$rulePasswordPolicy)
            $rulePasswordExpiration = $null
            [void][bool]::TryParse($rule.LoginPasswordExpirationEnabled, [ref]$rulePasswordExpiration)
            $ruleChangePassword = $null
            [void][bool]::TryParse($rule.LoginMustChangePassword, [ref]$ruleChangePassword)

            # New-Guid was added to be able to create multiple unique instances of this rule.
            SqlLogin ((Get-ResourceTitle -Rule $rule) + (New-Guid)) 
            {
                InstanceName                   = $instanceName
                ServerName                     = $serverName
                LoginType                      = $rule.LoginType
                Name                           = $login.Trim()
                LoginPasswordPolicyEnforced    = $rulePasswordPolicy
                LoginPasswordExpirationEnabled = $rulePasswordExpiration
                LoginMustChangePassword        = $ruleChangePassword
            }
        }
    }
}
