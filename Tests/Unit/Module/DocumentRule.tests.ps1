#region Header
using module .\..\..\..\Module\Rule.Document\Convert\DocumentRule.Convert.psm1
. $PSScriptRoot\.tests.header.ps1
#endregion
try
{
    InModuleScope -ModuleName "$($script:moduleName).Convert" {
        #region Test Setup
        $stigRule = Get-TestStigRule -ReturnGroupOnly
        $rule = [DocumentRuleConvert]::new( $stigRule )
        #endregion
        #region Class Tests
        Describe "$($rule.GetType().Name) Child Class" {

            Context 'Base Class' {

                It "Shoud have a BaseType of Rule" {
                    $rule.GetType().BaseType.ToString() | Should Be 'DocumentRule'
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
