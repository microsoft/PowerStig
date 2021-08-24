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
        #XML file has placeholder key words. This replaces the placeholder keywords with actual values for configuration.
        #$InstanceName = $Rule.InstanceName
        #$InstanceName = ($InstanceName) | ForEach-Object{$_.replace('SQLInstanceName',$SQLInstanceName)}

        #$ServerName = $Rule.ServerName
        #$ServerName = ($ServerName) | ForEach-Object{$_.replace('HostName',$HostName)}

        # Creates SQL Connection to Target Instance.
        $rootSqlConnection = New-Object System.Data.SqlClient.SqlConnection("Data Source = $sqlConnectionName ;Initial Catalog=Master;Integrated Security=SSPI;")
        $fetchSqlAuthLoginsQuery = 'SELECT name FROM sys.sql_logins WHERE principal_id != 1 AND name NOT LIKE ''#%'''
        $sqlAuthAdapter = New-Object System.Data.SqlClient.SqlDataAdapter($fetchSQLAuthLoginsQuery,$rootSQLConnection)
        $sqlAuthTable = New-Object System.Data.DataTable 'AuditSpec_Table'

        $rootSQLConnection.Open()
        $sqlAuthAdapter.Fill($sqlAuthTable)
        $rootSQLConnection.Close()

        foreach ($login in $sqlAuthTable)
        {
            $name = $login.Name

            # New-Guid was added to be able to create multiple unique instances of this rule.
            SqlLogin ((Get-ResourceTitle -Rule $rule) + (New-Guid)) 
            {
                #ServerInstance = $instance
                InstanceName                   = $instanceName
                ServerName                     = $serverName
                LoginType                      = $rule.LoginType
                Name                           = $name
                LoginMustChangePassword        = $rule.LoginMustChangePassword
                LoginPasswordPolicyEnforced    = $rule.LoginPasswordPolicyEnforced
                LoginPasswordExpirationEnabled = $rule.LoginPasswordExpirationEnabled
            }
        }
    }
}