#region Header
using module .\..\..\..\Module\Rule\Rule.psm1
. $PSScriptRoot\.tests.header.ps1
#endregion
try
{
    InModuleScope -ModuleName $script:moduleName {
        #region Test Setup
        $stig = [Rule]::new()
        $stig.InvokeClass( (Get-TestStigRule -ReturnGroupOnly) )
        #endregion
        #region Class Tests
        Describe "$($stig.GetType().Name) Base Class" {

            $type = $stig.GetType()

            It "Should be of BaseType '$($type.BaseType)'" {
                $type.BaseType.ToString() | Should Be 'System.Object'
            }

            Context 'InvokeClass with Stigdata element' {

                It 'Should return the rule Id' {
                    $stig.id | Should Be 'V-1000'
                }
                It 'Should return the Severity' {
                    $stig.severity | Should Be 'medium'
                }
                It 'Should return the Title' {
                    $stig.title | Should Be 'Sample Title'
                }
                It 'Should return the default status of pass' {
                    $stig.conversionstatus | Should Be 'pass'
                }
                It 'Should return the raw string' {
                    $stig.rawString | Should Not BeNullOrEmpty
                }
                It 'Should return decoded html in the rawString' {
                    $stig.rawString | Should Not Match '&\w+;'
                }
                It 'Should set IsNullOrEmptyt to false by default' {
                    $stig.IsNullOrEmpty | Should Be $false
                }
                It 'Should set OrganizationValueRequired to false by default' {
                    $stig.OrganizationValueRequired | Should Be $false
                }
                It 'Should OrganizationValueTestString to empty by default' {
                    $stig.OrganizationValueTestString | Should BeNullOrEmpty
                }
            }

            Context 'Methods' {

                $stigClassMethodNames = Get-StigBaseMethods

                foreach ( $method in $stigClassMethodNames )
                {
                    It "Should have a method named '$method'" {
                        ( $stig | Get-Member -Name $method ).Name | Should Be $method
                    }
                }
                # If new methods are added this will catch them so test coverage can be added
                It 'Should not have more methods than are tested' {
                    $memberPlanned = $stigClassMethodNames
                    $memberActual = ( $stig | Get-Member -MemberType Method ).Name
                    $compare = Compare-Object -ReferenceObject $memberActual -DifferenceObject $memberPlanned
                    $compare.Count | Should Be 0
                }
            }

            Context 'Static Methods' {

                $staticMethods = @('SplitCheckContent', 'GetFixText')

                foreach ( $method in $staticMethods )
                {
                    It "Should have a method named '$method'" {
                        ( [Rule] | Get-Member -Static -Name $method ).Name | Should Be $method
                    }
                }
                # If new methods are added this will catch them so test coverage can be added
                It 'Should not have more static methods than are tested' {
                    $memberPlanned = $staticMethods + @('Equals', 'new', 'ReferenceEquals')
                    $memberActual = ( [Rule] | Get-Member -Static -MemberType Method ).Name
                    $compare = Compare-Object -ReferenceObject $memberActual -DifferenceObject $memberPlanned
                    $compare.Count | Should Be 0
                }
            }
        }
        #endregion
        #region Method Tests
        Describe 'SplitCheckContent static method' {
            # This creates a multiline string with a blank line between them
            $checkContent = '
            Line 1

            Line 2
            '

            [string[]] $splitCheckContent = [Rule]::SplitCheckContent( $checkContent )

            It 'Should trim strings and remove empty lines' {
                $splitCheckContent[0] | Should Be 'Line 1'
                $splitCheckContent[1] | Should Be 'Line 2'
                $splitCheckContent[2] | Should BeNullOrEmpty
            }
        }

        Describe 'Encoding functions' {

            $encodedString = 'Local Computer Policy -&gt;-&gt; Computer Configuration -&gt;-&gt; '
            $decodedString = 'Local Computer Policy ->-> Computer Configuration ->-> '

            Context 'Test-HtmlEncoding' {

                It 'Should return true when encoded characters are found' {
                    Test-HtmlEncoding -CheckString $encodedString  | Should Be $true
                }
                It 'Should return false when encoded characters are found' {
                    Test-HtmlEncoding -CheckString $decodedString  | Should Be $false
                }
            }

            Context 'Test-HtmlEncoding' {

                It 'Should decode html encoding' {
                    ConvertFrom-HtmlEncoding -CheckString $encodedString | Should Be $decodedString
                }
            }
        }

        #endregion
        #region Function Tests

        #endregion
        #region Data Tests

        #endregion
    }
}
finally
{
    . $PSScriptRoot\.tests.footer.ps1
}
