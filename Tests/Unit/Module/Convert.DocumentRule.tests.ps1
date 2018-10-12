#region Header
using module .\..\..\..\Module\Convert.DocumentRule\Convert.DocumentRule.psm1
. $PSScriptRoot\.tests.header.ps1
#endregion
try
{
    InModuleScope -ModuleName $script:moduleName {
        #region Test Setup
        $rule = [DocumentRule]::new( (Get-TestStigRule -ReturnGroupOnly) )
        #endregion
        #region Class Tests
        Describe "$($rule.GetType().Name) Child Class" {

            Context 'Base Class' {

                It "Shoud have a BaseType of Rule" {
                    $rule.GetType().BaseType.ToString() | Should Be 'Rule'
                }
            }
        }
        #endregion
        #region Method Tests

        #endregion5
        #region Function Tests
        Describe "ConvertTo-DocumentRule" {
            $checkContent = 'If no accounts are members of the Backup Operators group, this is NA.

    Any accounts that are members of the Backup Operators group, including application accounts, must be documented with the ISSO.  If documentation of accounts that are members of the Backup Operators group is not maintained this is a finding.'
            <#
                This function can't really be unit tested, since the call cannot be mocked by pester, so
                the only thing we can really do at this point is to verify that it returns the correct object.
            #>
            $stigRule = Get-TestStigRule -CheckContent $checkContent -ReturnGroupOnly
            $rule = ConvertTo-DocumentRule -StigRule $stigRule

            It "Should return an DocumentRule object" {
                $rule.GetType() | Should Be 'DocumentRule'
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
