#region Header
. $PSScriptRoot\.tests.header.ps1
# endregion

try 
{
    InModuleScope -ModuleName "$($global:moduleName).Convert" {
        # region Test Setup
        $testRuleList = @(
            @{
                GetScript     = '# Fetches Named Pipes Protocol status
                $smoSqlConfigServices = New-Object Microsoft.SqlServer.Management.Smo.Wmi.ManagedComputer(''HostName'')

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
                TestScript    = '# Fetches Named Pipes Protocol status
                $smoSqlConfigServices = New-Object Microsoft.SqlServer.Management.Smo.Wmi.ManagedComputer(''HostName'')

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
                SetScript     = '# Sets the Named Pipes Protocol to disabled.
                $smoSqlConfigServices = New-Object Microsoft.SqlServer.Management.Smo.Wmi.ManagedComputer(''HostName'')

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
                CheckContent              = 'To determine the protocol(s) enabled for SQL Server, open SQL Server Configuration Manager. In the left-hand pane, expand SQL Server Network Configuration. Click on the entry for the SQL Server instance under review: "Protocols for ". The right-hand pane displays the protocols enabled for the instance. 

                                                    If Named Pipes is enabled and not specifically required and authorized, this is a finding. 

                                                    If any listed protocol is enabled but not authorized, this is a finding.'
                OrganizationValueRequired = $false
            }
        )
        # endregion

        # region Add Custom Tests Here

        Describe 'Method Function Tests'{
            foreach ($testRule in $testRuleList)
            {
                # Whitespace is removed from the script blocks to create a valid test.
                $getScript  = Get-GetScript -CheckContent $testRule.CheckContent
                $getScript  = ($getScript -replace "\s{2,}", " ")

                $testScript = Get-TestScript -CheckContent $testRule.CheckContent
                $testScript = ($testScript -replace "\s{2,}", " ")

                $setScript  = Get-SetScript -CheckContent $testRule.CheckContent
                $setScript  = ($setScript -replace "\s{2,}", " ")

                Context "PowerShellScriptQuery Get-GetScript"{
                    It 'Should return the get script block'{
                        $getScript | Should Be ($testRule.GetScript -replace "\s{2,}" , " ")
                    }
                }

                Context "PowerShellScriptQuery Get-TestScript"{
                    It 'Should return the test script block'{
                        $testScript | Should Be ($testRule.TestScript -replace "\s{2,}" , " ")
                    }
                }

                Context "PowerShellScriptQuery Get-SetScript"{
                    It 'Should return the set script block'{
                        $setScript | Should Be ($testRule.SetScript -replace "\s{2,}" , " ")
                    }
                }
            }
        }
    }
}
finally
{
    . $PSScriptRoot\.tests.footer.ps1
}
