#region Header
using module .\..\..\..\Module\Convert.WmiRule\Convert.WmiRule.psm1
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

        $rule = [WmiRule]::new( (Get-TestStigRule -ReturnGroupOnly) )
        #endregion
        #region Class Tests
        Describe "$($rule.GetType().Name) Child Class" {

            Context 'Base Class' {

                It 'Shoud have a BaseType of STIG' {
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

            Context 'Class Methods' {

                $classMethods = @()

                foreach ( $method in $classMethods )
                {
                    It "Should have a method named '$method'" {
                        ($rule | Get-Member -Name $method).Name | Should Be $method
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
        Describe 'ConvertTo-WmiRule' {
            <#
            This function can't really be unit tested, since the call cannot be mocked by pester, so
            the only thing we can really do at this point is to verify that it returns the correct object.
        #>
            $stigRule = Get-TestStigRule -CheckContent $checkContent -ReturnGroupOnly
            $rule = ConvertTo-WmiRule -StigRule $stigRule

            It 'Should return an WmiRule object' {
                $rule.GetType() | Should Be 'WmiRule'
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
