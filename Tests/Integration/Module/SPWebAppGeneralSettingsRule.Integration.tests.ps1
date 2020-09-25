#region Header
. $PSScriptRoot\.tests.header.ps1
#endregion

try
{
    $testCases = @(
        @{
            PropertyName    = 'SecurityValidation'
            PropertyValue   = 'True'
            DscResource     = 'SharePointSPWebAppGeneralSettings'
            CheckContent    = 'Review the SharePoint server configuration to ensure user sessions are terminated upon user logoff, and when idle time limit is exceeded.

            Navigate to Central Administration website.
            
            Click "Application Management".
            
            Click "Manage Web Applications".
            
            Repeat the following steps for each web application:
            -Select the web application.
            -Click "General Settings" in the "Web Application" ribbon.
            -In the "Web Page Security Validation" section, verify that "Security Validation is:" is set to "On" and that the "Security Validation Expires:" setting is set to 15 minutes.
            
            Otherwise, this is a finding.'
            ConversionStatus = 'pass'
        },
        @{
            PropertyName    = 'SecurityValidationTimeOutMinutes'
            PropertyValue   = '15'
            DscResource     = 'SharePointSPWebAppGeneralSettings'
            CheckContent    = 'Review the SharePoint server configuration to ensure a session lock occurs after 15 minutes of inactivity.

            In SharePoint Central Administration, click Application Management. 
            
            On the Application Management page, in the Web Applications section, click Manage web applications. 
            
            Verify that each web application meets this requirement.
            - Select the web application.
            - Select General Settings &gt;&gt; General Settings.
            - Navigate to the Web Page Security Validation section.
            - Verify that the Security Validation is "On" and set to expire after 15 minutes or less. 
            
            If Security Validation is "Off" or if the default time-out period is not set to 15 minutes or less for any of the web applications, this is a finding.'
            ConversionStatus = 'pass'
        },
        @{
            PropertyName    = 'BrowserFileHandling'
            PropertyValue   = 'Strict'
            DscResource     = 'SharePointSPWebAppGeneralSettings'
            CheckContent    = 'Review the SharePoint server configuration to ensure the execution of prohibited mobile code is prevented.

            Navigate to Central Administration.
            
            Click Manage Web Applications.
            
            For each Web Application in the Farm:
            -Click on the Web Application to configure.
            -Click on the drop-down box below General Settings.
            -Click on General Settings in the drop down box.
            -Under Browser File Handling, verify that "Strict" is selected.
            
            If "Strict" is not selected, this is a finding.'
            ConversionStatus = 'pass'
        },
        @{
            PropertyName    = 'AllowOnlineWebPartCatalog'
            PropertyValue   = 'False'
            DscResource     = 'SharePointSPWebAppGeneralSettings'
            CheckContent    = 'Review the SharePoint server configuration to ensure access to the online web part gallery is configured for limited access.

            Log on to Central Administration.
            
            Navigate to the Security page.
            
            Click on "Manage web part security".
            
            For each web application in the web application section, perform the following: 
            -Select the correct web application in the web application section.
            -Verify "Prevents users from accessing the Online Web Part Gallery, and helps to improve security and performance" option in the Online Web Part Gallery section is selected.
            
            If the "Prevents users from accessing the Online Web Part Gallery, and helps to improve security and performance" option in the Online Web Part Gallery section is not checked, this is a finding.'
            ConversionStatus = 'pass'
        }
    )

    Describe 'SPWebAppGeneralSettings Conversion' {
        foreach ($testCase in $testCases)
        {
            [xml] $stigRule = Get-TestStigRule -CheckContent $testCase.checkContent -XccdfTitle Windows
            $TestFile = Join-Path -Path $TestDrive -ChildPath 'TextData.xml'
            $stigRule.Save( $TestFile )
            $rule = ConvertFrom-StigXccdf -Path $TestFile

            It 'Should return a SPWebAppGeneralSettingsRule Object' {
                $rule.GetType() | Should Be 'SPWebAppGeneralSettingsRule'
            }

            It "Should return Property Name:'$($testCase.PropertyName)'" {
                $rule.PropertyName | Should Be $testCase.PropertyName
            }

            It "Should return Property Value:'$($testCase.PropertyValue)'"{
                $rule.PropertyValue | Should be $testCase.PropertyValue
            }

            It "Should set the correct DscResource" {
                $rule.DscResource | Should Be 'SharePointSPWebAppGeneralSettings'
            }
            
            It 'Should set the status to pass' {
                $rule.conversionstatus | Should be 'pass'
            }
        }
    }
}
finally
{
    . $PSScriptRoot\.tests.footer.ps1
}
