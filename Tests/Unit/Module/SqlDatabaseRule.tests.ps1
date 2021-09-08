#region Header
. $PSScriptRoot\.tests.header.ps1
#endregion

try 
{
    InModuleScope -ModuleName "$($global:moduleName).Convert" {
        #region Test Setup
        $testRuleList = @(
            @{
                Name                      = 'Pubs'
                Ensure                    = 'Absent'
                OrganizationValueRequired = $false
                CheckContent              = 'Review the server documentation, if this system is identified as a development or test system, this check is Not Applicable. 

                If this system is identified as production, gather a listing of databases from the server and look for any matching the following general demonstration database names: 
                
                pubs 
                Northwind
                AdventureWorks 
                WorldwideImporters 
                
                If any of these databases exist, this is a finding.'
            },
            @{
                Name                      = 'Northwind'
                Ensure                    = 'Absent'
                OrganizationValueRequired = $false
                CheckContent              = 'Review the server documentation, if this system is identified as a development or test system, this check is Not Applicable. 

                If this system is identified as production, gather a listing of databases from the server and look for any matching the following general demonstration database names: 
                
                pubs 
                Northwind
                AdventureWorks 
                WorldwideImporters 
                
                If any of these databases exist, this is a finding.'
            },
            @{
                Name                      = 'AdventureWorks'
                Ensure                    = 'Absent'
                OrganizationValueRequired = $false
                CheckContent              = 'Review the server documentation, if this system is identified as a development or test system, this check is Not Applicable. 

                If this system is identified as production, gather a listing of databases from the server and look for any matching the following general demonstration database names: 
                
                pubs 
                Northwind
                AdventureWorks 
                WorldwideImporters 
                
                If any of these databases exist, this is a finding.'
            },
            @{
                Name                      = 'WorldwideImporters'
                Ensure                    = 'Absent'
                OrganizationValueRequired = $false
                CheckContent              = 'Review the server documentation, if this system is identified as a development or test system, this check is Not Applicable. 

                If this system is identified as production, gather a listing of databases from the server and look for any matching the following general demonstration database names: 
                
                pubs 
                Northwind
                AdventureWorks 
                WorldwideImporters 
                
                If any of these databases exist, this is a finding.'
            }
        )
        #endregion

        $script:databasearray = @()
        foreach ($testRule in $testRuleList)
        {
            . $PSScriptRoot\Convert.CommonTests.ps1
        }

        #region Add Custom Tests Here
        Describe 'Method Function Tests' {
            $script:databasearray = @()
            foreach ($testRule in $testRuleList)
            {
                $databaseName = Get-DatabaseName -CheckContent $testRule.CheckContent

                Context "SqlDatabase Get-DatabaseName"{
                    It "Should return $($databaseName)" {
                        $databaseName | Should Be $testrule.Name
                    }
                }

                $ensureStatus = Set-Ensure -CheckContent $testRule.CheckContent

                Context "SqlDatabase Set-Ensure" {
                    It "Should return $($ensureStatus)" {
                        $ensureStatus | Should Be $testrule.Ensure
                    }
                }
            }
        }

        Describe 'Split Rule Tests' {
            $ruleCount = $databasearray.Count
            Context "Count of Rules"{
                It "Should return $ruleCount" {
                    $ruleCount | Should Be "4"
                }
            }
        }
    }
}

finally
{
    . $PSScriptRoot\.tests.footer.ps1
}
