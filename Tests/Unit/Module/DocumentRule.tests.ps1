s#region Header
using module .\..\..\..\Module\DocumentRule\DocumentRule.psm1
. $PSScriptRoot\.tests.header.ps1
#endregion
try
{
    InModuleScope -ModuleName $script:moduleName {
        #region Test Setup
        $stigRule = Get-TestStigRule -ReturnGroupOnly
        $rule = [DocumentRule]::new( $stigRule )
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

        #endregion

        #region Data Tests

        #endregion
    }
}
finally
{
    . $PSScriptRoot\.tests.footer.ps1
}
