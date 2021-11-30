#region Header
. $PSScriptRoot\.tests.header.ps1
#endregion

try 
{
    InModuleScope -ModuleName "$($global:moduleName).Convert" {
        #region Test Setup
        $testRuleList = @(
            @{
                LoginType                      = 'SqlLogin'
                LoginPasswordPolicyEnforced    = $true
                LoginPasswordExpirationEnabled = $true
                OrganizationValueRequired      = $true
                OrganizationValueTestString    = 'SQL authentication logins are populated from organizational settings.'
                CheckContent                   = 'Check for use of SQL Server Authentication:

                SELECT CASE SERVERPROPERTY(''IsIntegratedSecurityOnly'') WHEN 1 THEN ''Windows Authentication'' WHEN 0 THEN ''SQL Server Authentication'' END as [Authentication Mode]
                
                If the returned value in the “[Authentication Mode]” column is “Windows Authentication”, this is not a finding.
                
                SQL Server should be configured to inherit password complexity and password lifetime rules from the operating system.
                
                Review SQL Server to ensure logons are created with respect to the complexity settings and password lifetime rules by running the statement:
                
                SELECT [name], is_expiration_checked, is_policy_checked
                FROM sys.sql_logins
                
                Review any accounts returned by the query other than the disabled SA account, ##MS_PolicyTsqlExecutionLogin##, and ##MS_PolicyEventProcessingLogin##.
                
                If any account doesn''t have both "is_expiration_checked" and "is_policy_checked" equal to “1”, this is a finding.
                
                Review the Operating System settings relating to password complexity.
                
                Determine whether the following rules are enforced. If any are not, this is a finding.
                
                Check the server operating system for password complexity:
                
                Navigate to Start >> All Programs >> Administrative Tools >> Local Security Policy and to review the local policies on the machine. Account Policy >> Password Policy:
                
                Ensure the DISA Windows Password Policy is set on the SQL Server member server.'
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

                $loginType = Get-LoginType -CheckContent $testRule.CheckContent

                Context "SqlLogin Get-LoginType"{
                    It "Should return $($loginType)" {
                        $loginType | Should Be $testrule.LoginType
                    }
                }

                $passwordPolicy = Set-PasswordPolicy -CheckContent $testRule.CheckContent

                Context "SqlLogin Set-PasswordPolicy" {
                    It "Should return $($passwordPolicy)" {
                        $passwordPolicy | Should Be $testrule.LoginPasswordPolicyEnforced
                    }
                }

                $passwordExpiration = Set-PasswordExpiration -CheckContent $testRule.CheckContent

                Context "SqlLogin Set-PasswordExpiration" {
                    It "Should return $($passwordExpiration)" {
                        $passwordExpiration | Should Be $testrule.LoginPasswordExpirationEnabled
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
