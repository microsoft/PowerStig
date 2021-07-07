# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
#region Method Functions
<#
    .SYNOPSIS
        Sets the PowerShellScriptQueryRule GetScript from the check-content element in the xccdf.

    .PARAMETER CheckContent
        Specifies the check-content element in the xccdf
#>
function Get-GetScript
{
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $CheckContent
    )

    switch ($checkcontent) 
    {
        {$PSItem -Match 'Named Pipes'}
        {
            $getScript = '$smoSqlConfigServices = New-Object Microsoft.SqlServer.Management.Smo.Wmi.ManagedComputer(''HostName'')

                          if (''SQLConnectionName'' -notmatch ''\\'')
                          {
                             $smoSqlAgent = $smoSqlConfigServices.ServerInstances | Where-Object { $_.Name -eq ''SQLInstanceName'' }
                             $smoSqlNamedPipes = $smoSqlAgent.ServerProtocols | Where-Object { $_.Name -eq ''np'' }
                          }
                          else
                          {
                             $smoSqlAgent = $smoSqlConfigServices.ServerInstances | Where-Object { $_.Name -eq ''SQLInstanceName''.Split("{\}")[1] }
                             $smoSqlNamedPipes = $smoSqlAgent.ServerProtocols | Where-Object { $_.Name -eq ''np'' }
                          }

                          return @{Result = $smoSqlNamedPipes.IsEnabled}'
        }
        {$PSItem -Match 'setspn -L'}
        {
            $getScript = '$smoSqlConnection = New-Object Microsoft.SqlServer.Management.Smo.Server(''SQLConnectionName'')
                          $sqlServiceEngineAccount = $smoSqlConnection.ServiceAccount

                          $accountSPN = setspn -l $sqlServiceEngineAccount

                          $sqlSpnList = @{}

                          foreach ($spn in $accountSpn)
                          {
                              if ($spn -match "MSSQLSvc/$env:ComputerName*")
                              {
                                  $guid = New-Guid
                                  $sqlSpnList.Add($guid,$spn)
                              }
                          }

                          return @{Result = $sqlSpnList.Values}'
        }
    }

    return $getScript
}

<#
    .SYNOPSIS
        Sets the PowerShellScriptQueryRule TestScript from the check-content element in the xccdf.

    .PARAMETER CheckContent
        Specifies the check-content element in the xccdf
#>
function Get-TestScript
{
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $CheckContent
    )

    switch ($checkContent)
    {
        {$PSItem -Match 'Named Pipes'}
        {
            $testScript = '$smoSqlConfigServices = New-Object Microsoft.SqlServer.Management.Smo.Wmi.ManagedComputer(''HostName'')

                           if (''SQLConnectionName'' -notmatch ''\\'')
                           {
                               $smoSqlAgent = $smoSqlConfigServices.ServerInstances | Where-Object { $_.Name -eq ''SQLInstanceName'' }
                               $smoSqlNamedPipes = $smoSqlAgent.ServerProtocols | Where-Object { $_.Name -eq ''np'' }
                           }
                           else
                           {
                               $smoSqlAgent = $smoSqlConfigServices.ServerInstances | Where-Object { $_.Name -eq ''SQLInstanceName''.Split("{\}")[1] }
                               $smoSqlNamedPipes = $smoSqlAgent.ServerProtocols | Where-Object { $_.Name -eq ''np'' }
                           }

                           if ($smoSqlNamedPipes.IsEnabled -eq $True)
                           {
                               return $False
                           }
                           else
                           {
                               return $True
                           }'
        }
        {$PSItem -Match 'setspn -L'}
        {
            $testScript = '# Fetches SQL Server port in use.
                           $smoSqlConnection = New-Object Microsoft.SqlServer.Management.Smo.Server(''SQLConnectionName'')
                           $smoSqlConfigServices = New-Object Microsoft.SqlServer.Management.Smo.Wmi.ManagedComputer(''HostName'')
            
                           if (''SQLConnectionName'' -notmatch ''\\'')
                           {
                               $smoSqlAgent = $smoSqlConfigServices.ServerInstances | Where-Object { $_.Name -eq ''SQLInstanceName'' }
                           }
                           else
                           {
                               $smoSqlAgent = $SsmoSqlConfigServices.ServerInstances | Where-Object { $_.Name -eq ''SQLInstanceName''.Split("{\}")[1]}
                           }

                           $smoSqlTcpIp = $smoSqlAgent.ServerProtocols | Where-Object { $_.Name -eq ''tcp'' }
                           $smoSqlIpConfigs = $smoSqlTcpIp.IPAddresses | Where-Object { $_.Name -eq ''IPALL'' }
                           $smoSqlPort = $smoSqlIPConfigs.IPAddressProperties | Where-Object { $_.Name -eq ''TcpPort''} | Select-Object -Property Value

                           if (!$smoSqlPort.Value)
                           {
                               $smoSqlPort = $smoSqlIPConfigs.IPAddressProperties | Where-Object { $_.Name -eq ''TcpDynamicPorts'' } | Select-Object -Property Value
                           }

                           [string]$smoSqlPort = $smoSqlPort

                           # Fetches SQL Server service account in use.
                           $SqlServiceEngineAccount = $smoSqlConnection.ServiceAccount

                           # Fetches SPN currently created.
                           $fetchSqlSpn = SetSPN -l $sqlServiceEngineAccount

                           # Fetches FQDN.
                           $fetchDomain = (Get-WmiObject -Class Win32_ComputerSystem).Domain

                           # Removes whitespace from setspn command.
                           $formatFetchSqlSpn = @()
                           foreach ($badFormat in $fetchSqlSpn)
                           {
                               $formatFetchSqlSpn += [string]$badFormat.TrimStart()
                           }

                           $matchedSpn = @()
                           $listenerMatchedSpn = @()

                           # Determine if Always-On High Availability is enabled
                           $rootSqlConnection = New-Object System.Data.SqlClient.SqlConnection(''Data Source = SQLConnectionName ;Initial Catalog=Master;Integrated Security=SSPI;'')
                           $haQuery = ''SELECT SERVERPROPERTY(''''IsClustered'''') as IsClustered, SERVERPROPERTY(''''IsHadrEnabled'''') as IsHadrEnabled''
                           $haAdapter = New-Object System.Data.SqlClient.SqlDataAdapter($haQuery, $rootSqlConnection)
                           $haTable = New-Object System.Data.DataTable ''HA_Table''
                           $listenerTable = New-Object System.Data.DataTable ''Listener_Table''

                           $rootSqlConnection.Open()
                           $haAdapter.Fill($haTable) | Out-Null
                           $rootSqlConnection.Close()

                           # Compares SPN''s that exist to SPN''s that should exist for the Availability Group Listener
                           if ($HATable.IsHadrEnabled -eq "1")
                           {
                               $listenerQuery = ''SELECT dns_name, port from sys.availability_group_listeners''
                               $listenerAdapter = New-Object System.Data.SqlClient.SqlDataAdapter($listenerQuery, $rootSqlConnection)

                               $rootSqlConnection.Open()
                               $listenerAdapter.Fill($listenerTable) | Out-Null
                               $rootSqlConnection.Close()

                               # Verify a listener exists then compare
                               if ($listenerTable.Rows.Count -gt 0)
                               {
                                   $listenerSpn = @(''MSSQLSvc/'' + $listenerTable.dns_name + ''.'' + $FetchDomain + '':'' + $listenerTable.port), (''MSSQLSvc/'' + $listenerTable.dns_name + '':'' + $listenerTable.port)
                                   foreach ($existingSpn in $formatFetchSqlSpn)
                                   {
                                       foreach ($requiredSpn in $listenerSpn)
                                       {
                                           if ($requiredSpn -eq $existingSpn)
                                           {
                                               $listenerMatchedSpn += $requiredSpn
                                           }
                                        }
                                    }
                                }
                            }

                            # Compares SPN''s that exist to SPN''s that should exist for SQL Server.
                            if ($smoSqlConnection.ServiceName -eq ''MSSQLSERVER'')
                            {
                                $SqlSpn = @("MSSQLSvc/$env:ComputerName" + ''.'' + $fetchDomain + '':'' + $smoSqlPort.Split("{=}")[2]), ("MSSQLSvc/$env:ComputerName" + ''.'' + $fetchDomain)

                                foreach ($existingSpn in $formatFetchSqlSpn)
                                {
                                    foreach ($requiredSpn in $sqlSpn)
                                    {
                                        if ($requiredSpn -eq $existingSpn)
                                        {
                                            $matchedSpn += $requiredSpn
                                        }
                                    }
                                }
                            }
                            else
                            {
                                $SqlSpn = @("MSSQLSvc/$env:ComputerName" + ''.'' + $FetchDomain + '':'' + $smoSqlPort.Split("{=}")[2]), ("MSSQLSvc/$env:ComputerName" + ''.'' + $fetchDomain + '':'' + $smoSqlConnection.ServiceName)

                                foreach ($existingSpn in $formatFetchSqlSpn)
                                {
                                    foreach ($requiredSpn in $sqlSpn)
                                    {
                                        if ($requiredSpn -eq $existingSpn)
                                        {
                                            $matchedSpn += $requiredSpn
                                        }
                                    }
                                }
                            }

                            if ($matchedSpn.Count -lt 2 -or ($listenerTable.Rows.Count -gt 0 -and $listenerMatchedSpn.Count -lt 2))
                            {
                                return $False
                            }
                            else
                            {
                            return $True
                            }'
        }
    }

    return $testScript
}

<#
    .SYNOPSIS
        Sets the PowerShellScriptQueryRule SetScript from the check-content element in the xccdf.

    .PARAMETER CheckContent
        Specifies the check-content element in the xccdf
#>
function Get-SetScript
{
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $CheckContent
    )

    switch ($checkContent)
    {
        {$PSItem -Match 'Named Pipes'}
        {
            $setScript = '$smoSqlConfigServices = New-Object Microsoft.SqlServer.Management.Smo.Wmi.ManagedComputer(''HostName'')

                          if (''SQLConnectionName'' -notmatch ''\\'')
                          {
                              $smoSqlAgent = $smoSqlConfigServices.ServerInstances | Where-Object { $_.Name -eq ''SQLInstanceName'' }
                              $smoSqlNamedPipes = $smoSqlAgent.ServerProtocols | Where-Object { $_.Name -eq ''np'' }
                              $np = $smoSqlConfigServices.GetSmoObject($smoSqlNamedPipes.Urn.Value)
                              $np.IsEnabled = $False
                              $np.Alter()
                          }
                          else
                          {
                              $smoSqlAgent = $smoSqlConfigServices.ServerInstances | Where-Object { $_.Name -eq ''SQLInstanceName''.Split("{\}")[1] }
                              $smoSqlNamedPipes = $smoSqlAgent.ServerProtocols | Where-Object { $_.Name -eq ''np'' }
                              $np = $smoSqlConfigServices.GetSmoObject($smoSqlNamedPipes.Urn.Value)
                              $np.IsEnabled = $False
                              $np.Alter()
                          }'
        }
        {$PSItem -Match 'setspn -L'}
        {
            $setScript = '# Fetches SQL Server port in use.
            $smoSqlConnection = New-Object Microsoft.SqlServer.Management.Smo.Server(''SQLConnectionName'')
            $smoSqlConfigServices = New-Object Microsoft.SqlServer.Management.Smo.Wmi.ManagedComputer(''HostName'')
            
            if (''SQLConnectionName'' -notmatch ''\\'')
            {
                $smoSqlAgent = $smoSqlConfigServices.ServerInstances | Where-Object { $_.Name -eq ''SQLInstanceName'' }
            }
            else
            {
                $smoSqlAgent = $smoSqlConfigServices.ServerInstances | Where-Object { $_.Name -eq ''SQLInstanceName''.Split("{\}")[1] }
            }
            
            $smoSqlTcpIp = $smoSqlAgent.ServerProtocols | Where-Object { $_.Name -eq ''tcp'' }
            $smoSqlIPConfigs = $smoSqlTcpIp.IPAddresses | Where-Object { $_.Name -eq ''IPALL'' }
            $smoSqlPort = $smoSqlIPConfigs.IPAddressProperties | Where-Object { $_.Name -eq ''TcpPort'' } | Select-Object -Property Value
            
            if (!$smoSqlPort.Value)
            {
                $smoSqlPort = $smoSqlIPConfigs.IPAddressProperties | Where-Object { $_.Name -eq ''TcpDynamicPorts'' } | Select-Object -Property Value
            }
            
            [string]$smoSqlPort = $smoSqlPort
            
            # Fetches SQL Server service account in use.
            $sqlServiceEngineAccount = $smoSqlConnection.ServiceAccount
            
            # Fetches FQDN.
            $fetchDomain = (Get-WmiObject -Class Win32_ComputerSystem).Domain
            
            # Determine if Always-On High Availability is enabled
            $rootSqlConnection = New-Object System.Data.SqlClient.SqlConnection(''Data Source = SQLConnectionName ;Initial Catalog=Master;Integrated Security=SSPI;'')
            $haQuery = ''SELECT SERVERPROPERTY(''''IsClustered'''') as IsClustered, SERVERPROPERTY(''''IsHadrEnabled'''') as IsHadrEnabled''
            $haAdapter = New-Object System.Data.SqlClient.SqlDataAdapter($haQuery, $rootSqlConnection)
            $haTable = New-Object System.Data.DataTable ''HA_Table''
            $listenerTable = New-Object System.Data.DataTable ''Listener_Table''
            
            $rootSqlConnection.Open()
            $haAdapter.Fill($haTable) | Out-Null
            $rootSqlConnection.Close()
            
            # Determine if a listener exists
            if ($haTable.IsHadrEnabled -eq ''1'')
            {
                $listenerQuery = ''SELECT dns_name, port FROM sys.availability_group_listeners''
                $listenerAdapter = New-Object System.Data.SqlClient.SqlDataAdapter($listenerQuery, $rootSqlConnection)
            
                $rootSqlConnection.Open()
                $listenerAdapter.Fill($listenerTable) | Out-Null
                $rootSqlConnection.Close()
            
                if ($listenerTable.Rows.Count -gt 0)
                {
                    $listenerSpn = @(''MSSQLSvc/'' + $listenerTable.dns_name + ''.'' + $fetchDomain + '':'' + $listenerTable.port), (''MSSQLSvc/'' + $listenerTable.dns_name + '':'' + $listenerTable.port)
                    foreach ($spn in $listenerSpn)
                    {
                        setspn -s $spn $sqlServiceEngineAccount | Out-Null
                    }
                }
            }
            
            # Creates missing SQL Server Engine SPN''s.
            if ($smoSqlConnection.ServiceName -eq ''MSSQLSERVER'')
            {
                $SqlSpn = @("MSSQLSvc/$env:ComputerName" + ''.'' + $fetchDomain + '':'' + $smoSqlPort.Split("{=}")[2]), ("MSSQLSvc/$env:ComputerName" + ''.'' + $fetchDomain)
                foreach ($spn in $sqlSpn)
                {
                    setspn -s $spn $sqlServiceEngineAccount | Out-Null
                }
            }
            else
            {
                $sqlSpn = @("MSSQLSvc/$env:ComputerName" + ''.'' + $fetchDomain + '':'' + $smoSqlPort.Split("{=}")[2]), ("MSSQLSvc/$env:ComputerName" + ''.'' + $fetchDomain + '':'' + $smoSqlConnection.ServiceName)
                foreach ($spn in $sqlSpn)
                {
                    setspn -s $spn $sqlServiceEngineAccount | Out-Null
                }
            }'
        }
    }

    return $setScript
}

<#
    .SYNOPSIS
        Sets the PowerShellScriptQueryRule SetScript from the check-content element in the xccdf.

    .PARAMETER CheckContent
        Specifies the check-content element in the xccdf
#>
function Set-DependsOn
{
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $CheckContent
    )

    switch ($checkContent)
    {
        {$PSItem -Match 'Windows Start Menu and/or Control Panel,'}
        {
            $setDependsOn = '[SqlServerNetwork][V-213990][medium][SRG-APP-000383-DB-000364]::[SqlServer]BaseLine'
        }
        default
        {
            $setDependsOn = ''
        }
    }

    return $setDependsOn
}
