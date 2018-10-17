#region Header
using module .\..\..\..\Module\Convert.WebAppPoolRule\Convert.WebAppPoolRule.psm1
. $PSScriptRoot\.tests.header.ps1
#endregion
try
{
    InModuleScope -ModuleName $script:moduleName {
        #region Test Setup
        $rulesToTest = @(
            @{
                Key           = 'rapidFailProtection'
                Value         = '$true'
                CheckContent  = 'Open the IIS 8.5 Manager.

                Click the Application Pools.

                Perform for each Application Pool.

                Highlight an Application Pool to review and click "Advanced Settings" in the "Actions" pane.

                Scroll down to the "Rapid Fail Protection" section and verify the value for "Enabled" is set to "True".

                If the "Rapid Fail Protection:Enabled" is not set to "True", this is a finding.'
            }
            @{
                Key           = 'pingingEnabled'
                Value         = '$true'
                CheckContent  = 'Open the IIS 8.5 Manager.

                Click the Application Pools.

                Perform for each Application Pool.

                Highlight an Application Pool to review and click "Advanced Settings" in the "Actions" pane.

                Scroll down to the "Process Model" section and verify the value for "Ping Enabled" is set to "True".

                If the value for "Ping Enabled" is not set to "True", this is a finding.'
            }
        )

        $OrganizationValueTestString = @{
            key        = 'queueLength'
            TestString = '{0} -le 1000'
        }
        $rule = [WebAppPoolrule]::new( (Get-TestStigRule -ReturnGroupOnly) )
        #endregion
        #region Class Tests
        Describe "$($rule.GetType().Name) Child Class" {

            Context 'Base Class' {

                It 'Shoud have a BaseType of STIG' {
                    $rule.GetType().BaseType.ToString() | Should Be 'Rule'
                }
            }

            Context 'Class Properties' {

                $classProperties = @('Key', 'Value')

                foreach ( $property in $classProperties )
                {
                    It "Should have a property named '$property'" {
                        ( $rule | Get-Member -Name $property ).Name | Should Be $property
                    }
                }
            }

            Context 'Class Methods' {

                $classMethods = @('SetKeyValuePair', 'IsOrganizationalSetting', 'SetOrganizationValueTestString')

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
        foreach ( $rule in $rulesToTest )
        {
            Describe 'Get-KeyValuePair' {
                It "Should return $($rule.Key) and $($rule.Value)" {
                    $checkContent = Split-TestStrings -CheckContent $rule.CheckContent
                    $KeyValuePair = Get-KeyValuePair -CheckContent $checkContent
                    $KeyValuePair.Key | Should Be $rule.Key
                    $KeyValuePair.Value | Should Be $rule.Value
                }
            }
        }

        Describe 'Get-OrganizationValueTestString' {
            It 'Should return two rules' {
                $testString = Get-OrganizationValueTestString -Key $OrganizationValueTestString.Key
                $testString | Should Be $OrganizationValueTestString.TestString
            }
        }
        #endregion
        #region Function Tests
        Describe 'ConvertTo-WebAppPoolRule' {
            $stigRule = Get-TestStigRule -CheckContent $rulesToTest[1].checkContent -ReturnGroupOnly
            $rule = ConvertTo-WebAppPoolRule -StigRule $stigRule

            It 'Should return an WebAppPoolRule object' {
                $rule.GetType() | Should Be 'WebAppPoolRule'
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
