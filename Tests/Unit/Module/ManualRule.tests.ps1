#region Header
using module .\..\..\..\Module\Rule.Manual\Convert\ManualRule.Convert.psm1
. $PSScriptRoot\.tests.header.ps1
#endregion
try
{
    InModuleScope -ModuleName "$($script:moduleName).Convert" {
        #region Test Setup
        $checkContent = 'Verify servers are located in controlled access areas that are accessible only to authorized personnel.  If systems are not adequately protected, this is a finding.'
        $stigRule = Get-TestStigRule -CheckContent $checkContent -ReturnGroupOnly

        $rule = [ManualRuleConvert]::new( $stigRule )
        #endregion
        #region Class Tests
        Describe "$($rule.GetType().Name) Child Class" {

            Context 'Base Class' {

                It 'Shoud have a BaseType of Rule' {
                    $rule.GetType().BaseType.ToString() | Should Be 'ManualRule'
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
