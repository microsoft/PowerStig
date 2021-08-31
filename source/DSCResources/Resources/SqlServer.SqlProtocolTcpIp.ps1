# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$rules = $stig.RuleList | Select-Rule -Type SqlProtocolTcpIpRule

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
        # Creates SQL Connection to Target Instance.
        $rootSqlConnection = New-Object System.Data.SqlClient.SqlConnection("Data Source = $sqlConnectionName ;Initial Catalog=Master;Integrated Security=SSPI;")
        $fetchSqlTcpIpQuery = 'SELECT DISTINCT registry_key FROM sys.dm_server_registry WHERE registry_key LIKE ''%Tcp\IP%'''
        $sqlTcpIpAdapter = New-Object System.Data.SqlClient.SqlDataAdapter($fetchSqlTcpIpQuery,$rootSQLConnection)
        $sqlTcpIpTable = New-Object System.Data.DataTable 'TCPIP_Table'

        $rootSQLConnection.Open()
        $sqlTcpIpAdapter.Fill($sqlTcpIpTable)
        $rootSQLConnection.Close()

        foreach ($key in $sqlTcpIpTable.registry_key)
        {
            $ipAddressGroup = $key.Substring($key.LastIndexOf('\')).Split("\}")[1]

            # New-Guid was added to be able to create multiple unique instances of this rule.
            SqlProtocolTcpIp ((Get-ResourceTitle -Rule $rule) + (New-Guid)) 
            {
                InstanceName                   = $instanceName
                ServerName                     = $serverName
                TcpPort                        = $rule.TcpPort
                IpAddressGroup                 = $ipAddressGroup
            }
        }
    }
}