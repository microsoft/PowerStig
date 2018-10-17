#region Header
using module .\..\..\..\Module\Convert.ManualRule\Convert.ManualRule.psm1
. $PSScriptRoot\.tests.header.ps1
#endregion
try
{
    InModuleScope -ModuleName $script:moduleName {
        #region Test Setup
        $checkContent = 'Verify servers are located in controlled access areas that are accessible only to authorized personnel.  If systems are not adequately protected, this is a finding.'
        $rule = [ManualRule]::new( (Get-TestStigRule -ReturnGroupOnly) )
        #endregion
        #region Class Tests
        Describe "$($rule.GetType().Name) Child Class" {

            Context 'Base Class' {

                It 'Shoud have a BaseType of STIG' {
                    $rule.GetType().BaseType.ToString() | Should Be 'Rule'
                }
            }

            Context 'Class Properties' {}

            Context 'Class Methods' {
                $classMethods = @()

                foreach ( $method in $classMethods )
                {
                    It "Should have a method named '$method'" {
                        ( $rule | Get-Member -Name $method ).Name | Should Be $method
                    }
                }

                # If new methods are added this will catch them so test coverage can be added
                It 'Should not have more methods than are tested' {
                    $memberPlanned = Get-StigBaseMethods -ChildClassMethodNames $classMethods
                    $memberActual = ( $rule | Get-Member -MemberType Method ).Name
                    $compare = Compare-Object -ReferenceObject $memberActual -DifferenceObject $memberPlanned
                    $compare.Count | Should Be 0
                }
            }
        }
        #endregion
        #region Method Tests

        #endregion
        #region Function Tests
        Describe 'ConvertTo-ManualRule' {
            <#
            This function can't really be unit tested, since the call cannot be mocked by pester, so
            the only thing we can really do at this point is to verify that it returns the correct object.
        #>
            $stigRule = Get-TestStigRule -CheckContent $checkContent -ReturnGroupOnly
            $rule = ConvertTo-ManualRule -StigRule $stigRule

            It 'Should return an ManualRule object' {
                $rule.GetType() | Should Be 'ManualRule'
            }
        }
        #endregion
        #region Data Tests

        #endregion
    }
}
finally
{
    . $PSScriptRoot\.tests.footer.ps1
}
