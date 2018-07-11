#region Header
using module .\..\..\..\Module\Convert.WebConfigurationPropertyRule\Convert.WebConfigurationPropertyRule.psm1
. $PSScriptRoot\.tests.header.ps1
#endregion
try
{
    InModuleScope -ModuleName $script:moduleName {
        #region Test Setup
        $webConfigurationPropertyRule = @(
            @{
                ConfigSection = '/system.webServer/directoryBrowse'
                Key           = 'enabled'
                Value         = 'false'
                CheckContent  = 'Follow the procedures below for each site hosted on the IIS 8.5 web server:

                Click the Site.

                Double-click the "Directory Browsing" icon.

                If the "Directory Browsing" is not installed, this is Not Applicable.

                Under the "Actions" pane verify "Directory Browsing" is "Disabled".

                If "Directory Browsing" is not "Disabled", this is a finding.'
            }
            @{
                ConfigSection = '/system.web/sessionState'
                Key           = 'cookieless'
                Value         = 'UseURI'
                CheckContent  = 'Follow the procedures below for each site hosted on the IIS 8.5 web server:

                Open the IIS 8.5 Manager.

                Click the site name.

                Under the "ASP.NET" section, select "Session State".

                Under "Cookie Settings", verify the "Use URI" mode is selected from the "Mode:" drop-down list.

                If the "Use URI" mode is selected, this is not a finding.

                Alternative method:

                Click the site name.

                Select "Configuration Editor" under the "Management" section.

                From the "Section:" drop-down list at the top of the configuration editor, locate "system.web/sessionState".

                Verify the "cookieless" is set to "UseURI".

                If the "cookieless" is not set to "UseURI", this is a finding.'
            }
        )

        $splitwebConfigurationPropertyRule = @{
                CheckContent = 'Follow the procedures below for each site hosted on the IIS 8.5 web server:

                Access the IIS 8.5 Manager.

                Under "Management" section, double-click the "Configuration Editor" icon.

                From the "Section:" drop-down list, select "system.web/httpCookies".

                Verify the "require SSL" is set to "True".

                From the "Section:" drop-down list, select "system.web/sessionState".

                Verify the "compressionEnabled" is set to "False".

                If both the "system.web/httpCookies:require SSL" is set to "True" and the "system.web/sessionState:compressionEnabled" is set to "False", this is not a finding.'
        }

        $OrganizationValueTestString = @{
            key        = 'maxUrl'
            TestString = '{0} -le 4096'
        }
        $rule = [WebConfigurationPropertyRule]::new( (Get-TestStigRule -ReturnGroupOnly) )
        #endregion
        #region Class Tests
        Describe "$($rule.GetType().Name) Child Class" {

            Context 'Base Class' {

                It "Shoud have a BaseType of STIG" {
                    $rule.GetType().BaseType.ToString() | Should Be 'STIG'
                }
            }

            Context 'Class Properties' {

                $classProperties = @('ConfigSection', 'Key', 'Value')

                foreach ( $property in $classProperties )
                {
                    It "Should have a property named '$property'" {
                        ( $rule | Get-Member -Name $property ).Name | Should Be $property
                    }
                }
            }

            Context 'Class Methods' {

                $classMethods = @('SetConfigSection', 'SetKeyValuePair', 'IsOrganizationalSetting',
                    'SetOrganizationValueTestString')

                foreach ( $method in $classMethods )
                {
                    It "Should have a method named '$method'" {
                        ( $rule | Get-Member -Name $method ).Name | Should Be $method
                    }
                }

                # If new methods are added this will catch them so test coverage can be added
                It "Should not have more methods than are tested" {
                    $memberPlanned = Get-StigBaseMethods -ChildClassMethodNames $classMethods
                    $memberActual = ( $rule | Get-Member -MemberType Method ).Name
                    $compare = Compare-Object -ReferenceObject $memberActual -DifferenceObject $memberPlanned
                    $compare.Count | Should Be 0
                }
            }
        }
        #endregion
        #region Method Tests
        foreach ( $rule in $webConfigurationPropertyRule )
        {
            Describe 'Get-ConfigSection' {
                It "Should return $($rule.ConfigSection)" {
                    $ConfigSection = Get-ConfigSection -CheckContent ($rule.CheckContent -split '\n')
                    $ConfigSection | Should Be $rule.ConfigSection
                }
            }

            Describe 'Get-KeyValuePair' {
                It "Should return $($rule.Key) and $($rule.Value)" {
                    $KeyValuePair = Get-KeyValuePair -CheckContent ($rule.CheckContent -split '\n')
                    $KeyValuePair.Key | Should Be $rule.Key
                    $KeyValuePair.Value | Should Be $rule.Value
                }
            }
        }

        Describe 'Test-MultipleWebConfigurationPropertyRule' {
            foreach ( $rule in $webConfigurationPropertyRule )
            {
                It "Should return $false" {
                    $multipleRule = Test-MultipleWebConfigurationPropertyRule -CheckContent ($rule.CheckContent -split '\n')
                    $multipleRule | Should Be $false
                }
            }

            It "Should return $true" {
                $multipleRule = Test-MultipleWebConfigurationPropertyRule -CheckContent ($splitwebConfigurationPropertyRule.CheckContent -split '\n')
                $multipleRule | Should Be $true
            }
        }

        Describe 'Split-MultipleWebConfigurationPropertyRule' {
            It "Should return two rules" {
                $multipleRule = Split-MultipleWebConfigurationPropertyRule -CheckContent ($splitwebConfigurationPropertyRule.CheckContent -split '\n')
                $multipleRule.count | Should Be 2
            }
        }

        Describe 'Get-OrganizationValueTestString' {
            It "Should return two rules" {
                $testString = Get-OrganizationValueTestString -Key $OrganizationValueTestString.Key
                $testString | Should Be $OrganizationValueTestString.TestString
            }
        }
        #endregion
        #region Function Tests
        Describe "ConvertTo-WebConfigurationPropertyRule" {
            $stigRule = Get-TestStigRule -CheckContent $webConfigurationPropertyRule[1].checkContent -ReturnGroupOnly
            $rule = ConvertTo-WebConfigurationPropertyRule -StigRule $stigRule

            It "Should return an WebConfigurationPropertyRule object" {
                $rule.GetType() | Should Be 'WebConfigurationPropertyRule'
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
