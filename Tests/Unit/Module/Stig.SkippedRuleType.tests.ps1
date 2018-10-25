#region Header
using module .\..\..\..\Module\Stig.SkippedRuleType\Stig.SkippedRuleType.psm1
. $PSScriptRoot\.tests.header.ps1
#endregion
try
{
    InModuleScope -ModuleName $script:moduleName {
        #region Test Setup
        [string[]] $SkippedRuleTypeArray = @(
        "AccountPolicyRule",
        "AuditPolicyRule",
        "RegistryRule",
        "SecurityOptionRule",
        "ServiceRule",
        "UserRightRule"
        )
        #endregion
        #region Class Tests
        Describe 'SkippedRuleType Class' {

            Context 'Constructor' {

                It 'Should create an SkippedRuleType class instance using SkippedRuleType1 data' {
                    foreach ($type in $SkippedRuleTypeArray)
                    {
                        $SkippedRuleType = [SkippedRuleType]::new($type)
                        $SkippedRuleType.StigRuleType | Should Be $type
                    }
                }
            }

            Context 'Static Methods' {
                It 'ConvertFrom: Should be able to convert an array of SkippedRuleType strings to a SkippedRuleType array' {
                    $SkippedRuleTypes = [SkippedRuleType]::ConvertFrom($SkippedRuleTypeArray)

                    foreach ($type in $SkippedRuleTypeArray)
                    {
                        $skippedRuleType = $SkippedRuleTypes.Where( {$_.StigRuleType.ToString() -eq $type})
                        $skippedRuleType.StigRuleType | Should Be $type
                    }
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
