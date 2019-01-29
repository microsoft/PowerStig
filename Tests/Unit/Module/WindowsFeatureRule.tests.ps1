#region Header
using module .\..\..\..\Module\Rule.WindowsFeature\Convert\WindowsFeatureRule.Convert.psm1
. $PSScriptRoot\.tests.header.ps1
#endregion
try
{
    InModuleScope -ModuleName "$($script:moduleName).Convert" {
        #region Test Setup
        $stigRule = Get-TestStigRule -ReturnGroupOnly
        $rule = [WindowsFeatureRuleConvert]::new( $stigRule )
        #endregion
        #region Class Tests
        Describe "$($rule.GetType().Name) Child Class" {

            Context 'Base Class' {

                It 'Shoud have a BaseType of Rule' {
                    $rule.GetType().BaseType.ToString() | Should Be 'WindowsFeatureRule'
                }
            }

            Context 'Class Properties' {

                $classProperties = @('FeatureName', 'InstallState')

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

        #endregion
        #region Data Tests

        #endregion
    }
}
finally
{
    . $PSScriptRoot\.tests.footer.ps1
}
