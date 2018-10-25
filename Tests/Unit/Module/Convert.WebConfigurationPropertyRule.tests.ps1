#region Header
using module .\..\..\..\Module\Convert.WebConfigurationPropertyRule\Convert.WebConfigurationPropertyRule.psm1
. $PSScriptRoot\.tests.header.ps1
#endregion
try
{
    InModuleScope -ModuleName $script:moduleName {
        #region Test Setup
        $rulesToTest = @(
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

        $stigRule = Get-TestStigRule -CheckContent $rulesToTest[0].CheckContent -ReturnGroupOnly
        $rule = [WebConfigurationPropertyRule]::new( $stigRule )
        #endregion
        #region Class Tests
        Describe "$($rule.GetType().Name) Child Class" {

            Context 'Base Class' {

                It 'Shoud have a BaseType of STIG' {
                    $rule.GetType().BaseType.ToString() | Should Be 'Rule'
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
        }
        #endregion
        #region Method Tests
        foreach ( $rule in $rulesToTest )
        {
            Describe 'Get-ConfigSection' {
                It "Should return $($rule.ConfigSection)" {
                    $checkContent = Split-TestStrings -CheckContent $rule.CheckContent
                    Get-ConfigSection -CheckContent $checkContent | Should Be $rule.ConfigSection
                }
            }

            Describe 'Get-KeyValuePair' {
                It "Should return $($rule.Key) and $($rule.Value)" {
                    $checkContent = Split-TestStrings -CheckContent $rule.CheckContent
                    $KeyValuePair = Get-KeyValuePair -CheckContent $checkContent
                    $KeyValuePair.Key | Should Be $rule.Key
                    $KeyValuePair.Value | Should Be $rule.Value
                }
            }
        }

        Describe 'Test-MultipleWebConfigurationPropertyRule' {
            foreach ( $rule in $rulesToTest )
            {
                It "Should return $false" {
                    $checkContent = Split-TestStrings -CheckContent $rule.CheckContent
                    $multipleRule = Test-MultipleWebConfigurationPropertyRule -CheckContent $checkContent
                    $multipleRule | Should Be $false
                }
            }

            It "Should return $true" {
                $checkContent = Split-TestStrings -CheckContent $splitwebConfigurationPropertyRule.CheckContent
                $multipleRule = Test-MultipleWebConfigurationPropertyRule -CheckContent $checkContent
                $multipleRule | Should Be $true
            }
        }

        Describe 'Split-MultipleWebConfigurationPropertyRule' {
            It 'Should return two rules' {
                $checkContent = Split-TestStrings -CheckContent $splitwebConfigurationPropertyRule.CheckContent
                $multipleRule = Split-MultipleWebConfigurationPropertyRule -CheckContent $checkContent
                $multipleRule.count | Should Be 2
            }
        }

        Describe 'Get-OrganizationValueTestString' {
            It 'Should return two rules' {
                $testString = Get-OrganizationValueTestString -Key $OrganizationValueTestString.Key
                $testString | Should Be $OrganizationValueTestString.TestString
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
