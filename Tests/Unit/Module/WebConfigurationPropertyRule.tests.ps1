#region Header
. $PSScriptRoot\.tests.header.ps1
#endregion

try
{
    InModuleScope -ModuleName "$($global:moduleName).Convert" {
        #region Test Setup
        $testRuleList = @(
            @{
                ConfigSection = '/system.webServer/directoryBrowse'
                Key = 'enabled'
                Value = 'false'
                OrganizationValueRequired = $false
                CheckContent = 'Follow the procedures below for each site hosted on the IIS 8.5 web server:

                Click the Site.

                Double-click the "Directory Browsing" icon.

                If the "Directory Browsing" is not installed, this is Not Applicable.

                Under the "Actions" pane verify "Directory Browsing" is "Disabled".

                If "Directory Browsing" is not "Disabled", this is a finding.'
            },
            @{
                ConfigSection = '/system.web/sessionState'
                Key = 'cookieless'
                Value = 'UseURI'
                OrganizationValueRequired = $false
                CheckContent = 'Follow the procedures below for each site hosted on the IIS 8.5 web server:

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
            },
            @{
                ConfigSection = '/system.webServer/security/requestFiltering/requestlimits'
                Key = 'maxUrl'
                Value = ''
                OrganizationValueRequired = $true
                OrganizationValueTestString = '{0} -le 4096'
                CheckContent = 'Follow the procedures below for each site hosted on the IIS 8.5 web server:

                Open the IIS 8.5 Manager.

                Click on the site name.

                Double-click the "Request Filtering" icon.

                Click “Edit Feature Settings” in the "Actions" pane.

                If the "maxUrl" value is not set to "4096" or less, this is a finding.'
            }
            # TODO There are many switch options in Get-ConfigSection that are not tested in Test data
        )
        #endregion

        foreach ($testRule in $testRuleList)
        {
            . $PSScriptRoot\Convert.CommonTests.ps1
        }

        #region Add Custom Tests Here
        Describe 'MultipleRules' {
            # TODO move this to the CommonTests
            $testRuleList = @(
                @{
                    Count = 2
                    CheckContent = 'Follow the procedures below for each site hosted on the IIS 8.5 web server:

                    Access the IIS 8.5 Manager.

                    Under "Management" section, double-click the "Configuration Editor" icon.

                    From the "Section:" drop-down list, select "system.web/httpCookies".

                    Verify the "require SSL" is set to "True".

                    From the "Section:" drop-down list, select "system.web/sessionState".

                    Verify the "compressionEnabled" is set to "False".

                    If both the "system.web/httpCookies:require SSL" is set to "True" and the "system.web/sessionState:compressionEnabled" is set to "False", this is not a finding.'
                }
            )
            foreach ($testRule in $testRuleList)
            {
                It "Should return $true" {
                    $multipleRule = [WebConfigurationPropertyRuleConvert]::HasMultipleRules($testRule.CheckContent)
                    $multipleRule | Should -Be $true
                }
                It "Should return $($testRule.Count) rules" {
                    $multipleRule = [WebConfigurationPropertyRuleConvert]::SplitMultipleRules($testRule.CheckContent)
                    $multipleRule.count | Should -Be $testRule.Count
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
