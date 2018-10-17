#region Header
. $PSScriptRoot\.tests.header.ps1
#endregion
try
{
    #region Test Setup
    $stigRulesToTest = @(
        @{
            ConfigSection = '/system.webServer/security/requestFiltering'
            Key           = 'allowHighBitCharacters'
            Value         = 'false'
            CheckContent  = 'Follow the procedures below for each site hosted on the IIS 8.5 web server:

            Open the IIS 8.5 Manager.
            
            Click on the site name.
            
            Double-click the "Request Filtering" icon.
            
            Click Edit Feature Settings in the "Actions" pane.
            
            If the "Allow high-bit characters" check box is checked, this is a finding.'
        }
        @{
            ConfigSection = '/system.webServer/security/requestFiltering'
            Key           = 'allowDoubleEscaping'
            Value         = 'false'
            CheckContent  = 'Follow the procedures below for each site hosted on the IIS 8.5 web server:

            Open the IIS 8.5 Manager.
            
            Click on the site name.
            
            Double-click the "Request Filtering" icon.
            
            Click Edit Feature Settings in the "Actions" pane.
            
            If the "Allow double escaping" check box is checked, this is a finding.'
        }
    )
    #endregion
    #region Tests
    Describe 'WebConfigurationProperty Rule Conversion' {

        foreach ( $stig in $stigRulesToTest )
        {
            [xml] $stigRule = Get-TestStigRule -CheckContent $stig.CheckContent -XccdfTitle 'IIS'
            $TestFile = Join-Path -Path $TestDrive -ChildPath 'TextData.xml'
            $stigRule.Save( $TestFile )
            $rule = ConvertFrom-StigXccdf -Path $TestFile

            It 'Should return an WebConfigurationPropertyRule Object' {
                $rule.GetType() | Should Be 'WebConfigurationPropertyRule'
            }

            It "Should return ConfigSection '$($stig.ConfigSection)'" {
                $rule.ConfigSection | Should Be $stig.ConfigSection
            }

            It "Should return Key '$($stig.Key)'" {
                $rule.Key | Should Be $stig.Key
            }

            It "Should return Value '$($stig.Value)'" {
                $rule.Value | Should Be $stig.Value
            }

            It 'Should Set the status to pass' {
                $rule.ConversionStatus | Should Be 'pass'
            }
        }
    }
    #endregion
}
finally
{
    . $PSScriptRoot\.tests.footer.ps1
}
