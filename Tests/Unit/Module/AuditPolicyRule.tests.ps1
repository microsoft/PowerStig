#region Header
using module .\..\..\..\Module\Rule.AuditPolicy\Convert\AuditPolicyRule.Convert.psm1
. $PSScriptRoot\.tests.header.ps1
#endregion
try
{
    InModuleScope -ModuleName "$($script:moduleName).Convert" {
        #region Test Setup
        $checkContentBase = 'Security Option "Audit: Force audit policy subcategory settings (Windows Vista or later) to override audit policy category settings" must be set to "Enabled" (V-14230) for the detailed auditing subcategories to be effective.

Use the AuditPol tool to review the current Audit Policy configuration:
-Open a Command Prompt with elevated privileges ("Run as Administrator").
-Enter "AuditPol /get /category:*".

Compare the AuditPol settings with the following.
If the system does not audit the following, this is a finding.

{0}'

        $checkContentString = 'Account Management -&gt; Computer Account Management - Success'
        $stigRule = Get-TestStigRule -CheckContent ($checkContentBase -f $checkContentString) -ReturnGroupOnly
        $rule = [AuditPolicyRuleConvert]::new( $stigRule )
        #endregion
        #region Class Tests
        Describe "$($rule.GetType().Name) Child Class" {

            Context 'Base Class' {

                It 'Shoud have a BaseType of STIG' {
                    $rule.GetType().BaseType.ToString() | Should -Be 'AuditPolicyRule'
                }
            }

            Context 'Class Properties' {

                $classProperties = @('Subcategory', 'AuditFlag', 'Ensure')

                foreach ( $property in $classProperties )
                {
                    It "Should have a property named '$property'" {
                        ( $rule | Get-Member -Name $property ).Name | Should -Be $property
                    }
                }
            }
        }
        #endregion
        #region Method Tests
        Describe 'Conversion' {

            Context 'Data format "->"' {
                $checkContentString = 'Account Management -> Computer Account Management - Success'
                $stigRule = Get-TestStigRule -CheckContent ($checkContentBase -f $checkContentString) -ReturnGroupOnly
                $rule = [AuditPolicyRuleConvert]::new( $stigRule )

                It 'Should return the SubCategory' {
                    $rule.Subcategory | Should -Be 'Computer Account Management'
                }
                It 'Should return the audit flag' {
                    $rule.AuditFlag | Should -Be 'Success'
                }
            }

            Context 'Data format ">>"' {

                $checkContentString = 'Account Management &gt;&gt; Computer Account Management - Success'
                $stigRule = Get-TestStigRule -CheckContent ($checkContentBase -f $checkContentString) -ReturnGroupOnly
                $rule = [AuditPolicyRuleConvert]::new( $stigRule )

                It 'Should return the SubCategory' {
                    $rule.Subcategory | Should -Be 'Computer Account Management'
                }
                It 'Should return the audit flag' {
                    $rule.AuditFlag | Should -Be 'Success'
                }
            }
            Context 'forward slash in subcategory' {

                $checkContentString = 'Logon/Logoff &gt;&gt; Account Lockout - Success'
                $stigRule = Get-TestStigRule -CheckContent ($checkContentBase -f $checkContentString) -ReturnGroupOnly
                $rule = [AuditPolicyRuleConvert]::new( $stigRule )

                It 'Should return the SubCategory' {
                    $rule.Subcategory | Should -Be 'Account Lockout'
                }
                It 'Should return the audit flag' {
                    $rule.AuditFlag | Should -Be 'Success'
                }
            }
        }

        #endregion
    }
}
finally
{
    . $PSScriptRoot\.tests.footer.ps1
}
