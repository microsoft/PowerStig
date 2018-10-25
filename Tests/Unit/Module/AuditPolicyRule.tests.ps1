#region Header
using module .\..\..\..\Module\AuditPolicyRule\AuditPolicyRule.psm1
. $PSScriptRoot\.tests.header.ps1
#endregion
try
{
    InModuleScope -ModuleName $script:moduleName {
        #region Test Setup
        $checkContentBase = 'Security Option "Audit: Force audit policy subcategory settings (Windows Vista or later) to override audit policy category settings" must be set to "Enabled" (V-14230) for the detailed auditing subcategories to be effective.

        Use the AuditPol tool to review the current Audit Policy configuration:
        -Open a Command Prompt with elevated privileges ("Run as Administrator").
        -Enter "AuditPol /get /category:*".

        Compare the AuditPol settings with the following.  If the system does not audit the following, this is a finding.

        {0}'

        $checkContentString = 'Account Management -&gt; Computer Account Management - Success'
        $stigRule = Get-TestStigRule -CheckContent ($checkContentBase -f $checkContentString) -ReturnGroupOnly
        $rule = [AuditPolicyRule]::new( $stigRule )
        #endregion
        #region Class Tests
        Describe "$($rule.GetType().Name) Child Class" {

            Context 'Base Class' {

                It 'Shoud have a BaseType of STIG' {
                    $rule.GetType().BaseType.ToString() | Should Be 'Rule'
                }
            }

            Context 'Class Properties' {

                $classProperties = @('Subcategory', 'AuditFlag', 'Ensure')

                foreach ( $property in $classProperties )
                {
                    It "Should have a property named '$property'" {
                        ( $rule | Get-Member -Name $property ).Name | Should Be $property
                    }
                }
            }
        }
        #endregion
        #region Method Tests
        $checkContentString = 'Account Management -> Computer Account Management - Success'

        Describe 'Get-AuditPolicySettings' {

            Context 'Data format "->"' {

                $checkContent = Split-TestStrings -CheckContent ($checkContentBase -f $checkContentString)
                $settings = Get-AuditPolicySettings -CheckContent $checkContent

                It 'Should return the Category in the first index' {
                    $settings[0] | Should Match '(\s)*Account Management(\s)*'
                }
                It 'Should return the SubCategory in the second index' {
                    $settings[1] | Should Match '(\s)*Computer Account Management(\s)*'
                }
                It 'Should return the audit flag in the third index' {
                    $settings[2] | Should Match '(\s)*Success(\s)*'
                }
            }

            Context 'Data format ">>"' {

                $checkContentString = 'Account Management >> Computer Account Management - Success'
                $checkContent = Split-TestStrings -CheckContent ($checkContentBase -f $checkContentString)
                $settings = Get-AuditPolicySettings -CheckContent $checkContent

                It 'Should return the Category in the first index' {
                    $settings[0] | Should Match '(\s)*Account Management(\s)*'
                }
                It 'Should return the SubCategory in the second index' {
                    $settings[1] | Should Match '(\s)*Computer Account Management(\s)*'
                }
                It 'Should return the audit flag in the third index' {
                    $settings[2] | Should Match '(\s)*Success(\s)*'
                }
            }
        }

        Describe 'Get-AuditPolicySubCategory' {

            #Mock -CommandName Get-AuditPolicySettings -MockWith { @('Category ', ' Subcategory ', ' Flag') }
            $checkContent = Split-TestStrings -CheckContent ($checkContentBase -f $checkContentString)
            It 'Should return the second string in quotes' {
                Get-AuditPolicySubCategory -CheckContent $checkContent | Should Be 'Computer Account Management'
            }
        }

        Describe 'Get-AuditPolicyFlag' {

            $checkContent = Split-TestStrings -CheckContent ($checkContentBase -f $checkContentString)
            It 'Should return the audit policy flag' {
                Get-AuditPolicyFlag -CheckContent $checkContent | Should Be 'Success'
            }
        }
        #endregion

        #region Data Tests
        Describe 'Audit Policy Data Variables' {

            [string[]] $dataSectionNameList = @(
                'auditPolicySubcategories',
                'auditPolicyFlags',
                'auditPolicyRegularExpressions'
            )

            foreach ($dataSectionName in $dataSectionNameList)
            {
                It "Should have a data section '$dataSectionName'" {
                    ( Get-Variable -Name $dataSectionName ).Name | Should Be $dataSectionName
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
