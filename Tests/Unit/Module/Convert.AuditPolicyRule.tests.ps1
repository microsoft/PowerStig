#region Header
using module .\..\..\..\Module\Convert.AuditPolicyRule\Convert.AuditPolicyRule.psm1
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
        $rule = [AuditPolicyRule]::new( (Get-TestStigRule -ReturnGroupOnly) )
        #endregion
        #region Class Tests
        Describe "$($rule.GetType().Name) Child Class" {

            Context 'Base Class' {

                It "Shoud have a BaseType of STIG" {
                    $rule.GetType().BaseType.ToString() | Should Be 'STIG'
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

            Context 'Class Methods' {

                $classMethods = @('SetSubcategory', 'SetAuditFlag', 'SetEnsureFlag')

                foreach ( $method in $classMethods )
                {
                    It "Should have a method named '$method'" {
                        ( $rule | Get-Member -Name $method ).Name | Should Be $method
                    }
                }

                # If new methods are added this will catch them so test coverage can be added
                It "Should not have more methods than are tested" {
                    $memberPlanned = Get-StigBaseMethods -ChildClassMethodNames $classMethods
                    $memberActual = ( $rule | Get-Member -MemberType Method ).Name
                    $compare = Compare-Object -ReferenceObject $memberActual -DifferenceObject $memberPlanned
                    $compare.Count | Should Be 0
                }
            }
        }
        #endregion
        #region Method Tests
        $string = 'Account Management -> Computer Account Management - Success'

        Describe 'Get-AuditPolicySettings' {
    
            Context 'Data format "->"' {
    
                $checkContent = ($checkContentBase -f $string) -split '\n'
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
    
                $string = 'Account Management >> Computer Account Management - Success'
                $checkContent = ($checkContentBase -f $string) -split '\n'
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
            $checkContent = ($checkContentBase -f $string) -split '\n'
            It 'Should return the second string in quotes' {
                Get-AuditPolicySubCategory -CheckContent $checkContent | Should Be 'Computer Account Management'
            }
        }
    
        Describe 'Get-AuditPolicyFlag' {
    
            #Mock -CommandName Get-AuditPolicySettings -MockWith { @('Category ', ' Subcategory ', ' Flag') }
            $checkContent = ($checkContentBase -f $string) -split '\n'
            It 'Should return the audit policy flag' {
                Get-AuditPolicyFlag -CheckContent $checkContent | Should Be 'Success'
            }
        }
        #endregion
        #region Function Tests
        $checkContent = 'Security Option "Audit: Force audit policy subcategory settings (Windows Vista or later) to override audit policy category settings" must be set to "Enabled" (V-14230) for the detailed auditing subcategories to be effective.

    Use the AuditPol tool to review the current Audit Policy configuration:
    -Open a Command Prompt with elevated privileges ("Run as Administrator").
    -Enter "AuditPol /get /category:*".
    
    Compare the AuditPol settings with the following.  If the system does not audit the following, this is a finding.
    
    Account Management -&gt; Computer Account Management - Success'

        Describe "ConvertTo-AuditPolicyRule" {
            <#
            This function can't really be unit tested, since the call cannot be mocked by pester, so
            the only thing we can really do at this point is to verify that it returns the correct object.
        #>
            $stigRule = Get-TestStigRule -CheckContent $checkContent -ReturnGroupOnly
            $rule = ConvertTo-AuditPolicyRule -StigRule $stigRule

            It "Should return an AuditPolicyRule object" {
                $rule.GetType() | Should Be 'AuditPolicyRule'
            }
        }
        #endregion
        #region Data Tests
        Describe "Audit Policy Data Variables" {
    
            [string[]] $dataSectionNameList = @(
                'auditPolicySubcategories',
                'auditPolicyFlags',
                'auditPolicyRegularExpressions'
            )

            foreach ($dataSectionName in $dataSectionNameList)
            {
                It "Should have a data section '$dataSectionName" {
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
