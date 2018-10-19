#region Header
using module .\..\..\..\Module\WmiRule\WmiRule.psm1
. $PSScriptRoot\.tests.header.ps1
#endregion
try
{
    InModuleScope -ModuleName $script:moduleName {
        #region Test Setup
        $checkContent = 'Open the Computer Management Console.
        Expand the "Storage" object in the Tree window.
        Select the "Disk Management" object.

        If the file system column does not indicate "NTFS" as the file system for each local hard drive, this is a finding.

        Some hardware vendors create a small FAT partition to store troubleshooting and recovery data. No other files must be stored here.  This
        must be documented with the ISSO.'

        $stigRule = Get-TestStigRule -CheckContent $checkContent -ReturnGroupOnly
        $rule = [WmiRule]::new( $stigRule )
        #endregion
        #region Class Tests
        Describe "$($rule.GetType().Name) Child Class" {

            Context 'Base Class' {

                It "Shoud have a BaseType of STIG" {
                    $rule.GetType().BaseType.ToString() | Should Be 'Rule'
                }
            }

            Context 'Class Properties' {

                $classProperties = @('Query', 'Property', 'Value', 'Operator')

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
