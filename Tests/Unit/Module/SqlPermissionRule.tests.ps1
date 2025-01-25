#region Header
. $PSScriptRoot\.tests.header.ps1
#endregion

try 
{
    InModuleScope -ModuleName "$($global:moduleName).Convert" {
        #region Test Setup
        $testRuleList = @(
            @{
                Name            = 'NT AUTHORITY\SYSTEM'
                Permission      = 'CONNECTSQL,VIEWANYDATABASE'
                CheckContent    = 'Execute the following queries. The first query checks for Clustering and Availability Groups being provisioned in the Database Engine. The second query lists permissions granted to the Local System account.

                                    SELECT
                                        SERVERPROPERTY(''IsClustered'') AS [IsClustered],
                                        SERVERPROPERTY(''IsHadrEnabled'') AS [IsHadrEnabled]

                                    EXECUTE AS LOGIN = ''NT AUTHORITY\SYSTEM''

                                    SELECT * FROM fn_my_permissions(NULL, ''server'')

                                    REVERT

                                    GO

                                    
                                    If IsClustered returns 1, IsHadrEnabled returns 0, and any permissions have been granted to the Local System account beyond "CONNECT SQL", "VIEW SERVER STATE", and "VIEW ANY DATABASE", this is a finding.
                                    
                                    If IsHadrEnabled returns 1 and any permissions have been granted to the Local System account beyond "CONNECT SQL", "CREATE AVAILABILITY GROUP", "ALTER ANY AVAILABILITY GROUP", "VIEW SERVER STATE", and "VIEW ANY DATABASE", this is a finding.
                                    
                                    If both IsClustered and IsHadrEnabled return 0 and any permissions have been granted to the Local System account beyond "CONNECT SQL" and "VIEW ANY DATABASE", this is a finding.'
            }
        )
        #endregion

        foreach ($testRule in $testRuleList)
        {
            . $PSScriptRoot\Convert.CommonTests.ps1
        }

        #region Add Custom Tests Here
        Describe 'Method Function Tests' {
            foreach ($testRule in $testRuleList)
            {

                $name = Set-LoginName -CheckContent $testRule.CheckContent

                Context "SqlPermission Get-Name"{
                    It "Should return $($name)" {
                        $name | Should Be $testrule.Name
                    }
                }

                $permission = Set-Permission -CheckContent $testRule.CheckContent

                Context "SqlPermission Get-Permission"{
                    It "Should return $($permission)" {
                        $permission | Should Be $testrule.Permission
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