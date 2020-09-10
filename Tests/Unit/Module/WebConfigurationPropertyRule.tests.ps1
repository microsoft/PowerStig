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
            },
            @{
                ConfigSection = '/system.web/trust'
                Key = 'level'
                Value = ''
                OrganizationValueRequired = $true
                OrganizationValueTestString = "'{0}' -cmatch '^(Full|High)$'"
                CheckContent = 'Note: If the server being reviewed is a non-production website, this is Not Applicable.

                Follow the procedures below for each site hosted on the IIS 10.0 web server:

                Open the IIS 10.0 Manager.

                Click the site name under review.

                Double-click the ".NET Trust Level" icon.

                If the ".NET Trust Level" is not set to Full or less, this is a finding.'
            },
            @{
                ConfigSection = '/system.web/compilation'
                Key = 'debug'
                Value = 'false'
                OrganizationValueRequired = $false
                CheckContent = 'Note: If the ".NET feature" is not installed, this check is Not Applicable.

                Follow the procedures below for each site hosted on the IIS 10.0 web server:

                Open the IIS 10.0 Manager.

                Click the site name under review.

                Double-click ".NET Compilation".

                Scroll down to the "Behavior" section and verify the value for "Debug" is set to "False".

                If the "Debug" value is not set to "False", this is a finding.'
            },
            @{
                ConfigSection = '/system.webServer/security/requestFiltering'
                Key = 'allowHighBitCharacters'
                Value = 'false'
                OrganizationValueRequired = $false
                CheckContent = 'Follow the procedures below for each site hosted on the IIS 10.0 web server:

                Open the IIS 10.0 Manager.

                Click the site name.

                Double-click the "Request Filtering" icon.

                Click "Edit Feature Settings" in the "Actions" pane.

                If the "Allow high-bit characters" check box is checked, this is a finding.

                Note: If this IIS 10.0 installation is supporting Microsoft Exchange, and not otherwise hosting any content, this requirement is Not Applicable.'
            },
            @{
                ConfigSection = '/system.webServer/security/requestFiltering/fileExtensions'
                Key = 'allowUnlisted'
                Value = 'false'
                OrganizationValueRequired = $false
                CheckContent = 'Follow the procedures below for each site hosted on the IIS 10.0 web server:

                Open the IIS 10.0 Manager.

                Click the site name.

                Double-click the "Request Filtering" icon.

                Click "Edit Feature Settings" in the "Actions" pane.

                If the "Allow unlisted file name extensions" check box is checked, this is a finding.

                Note: If this IIS 10.0 installation is supporting Microsoft Exchange, and not otherwise hosting any content, this requirement is Not Applicable.'
            },
            @{
                ConfigSection = '/system.webServer/httpErrors'
                Key = 'errormode'
                Value = 'DetailedLocalOnly'
                OrganizationValueRequired = $false
                CheckContent = 'Follow the procedures below for each site hosted on the IIS 10.0 web server:

                Open the IIS 10.0 Manager.

                Click the site name under review.

                Double-click the "Error Pages" icon.

                Click each error message and click "Edit Feature" setting from the "Actions" pane.

                If any error message is not set to "Detailed errors for local requests and custom error pages for remote requests", this is a finding.'
            },
            @{
                ConfigSection = '/system.webServer/asp/session'
                Key = 'keepSessionIdSecure'
                Value = 'True'
                OrganizationValueRequired = $false
                CheckContent = 'Follow the procedures below for each site hosted on the IIS 10.0 web server:

                Access the IIS 10.0 Manager.

                Select the website being reviewed.

                Under "Management" section, double-click the "Configuration Editor" icon.

                From the "Section:" drop-down list, select "system.webServer/asp".

                Expand the "session" section.

                Verify the "keepSessionIdSecure" is set to "True".

                If the "keepSessionIdSecure" is not set to "True", this is a finding.'
            },
            @{
                ConfigSection = '/system.web/sessionState'
                Key = 'cookieless'
                Value = 'UseCookies'
                OrganizationValueRequired = $false
                CheckContent = 'Follow the procedures below for each site hosted on the IIS 10.0 web server:

                Open the IIS 10.0 Manager.

                Click the site name.

                Under the "ASP.NET" section, select "Session State".

                Under "Cookie Settings", verify the "Use Cookies" mode is selected from the "Mode:" drop-down list.

                If the "Use Cookies" mode is selected, this is not a finding.

                Alternative method:

                Click the site name.

                Select "Configuration Editor" under the "Management" section.

                From the "Section:" drop-down list at the top of the configuration editor, locate "system.web/sessionState".

                Verify the "cookieless" is set to "UseCookies".

                If the "cookieless" is not set to "UseCookies", this is a finding.

                Note: If IIS 10.0 server/site is used only for system-to-system maintenance, does not allow users to connect to interface, and is restricted to specific system IPs, this is Not Applicable.'
            },
            @{
                ConfigSection = $null
                Key = $null
                Value = $null
                OrganizationValueRequired = $false
                CheckContent = 'Follow the procedures below for each site hosted on the IIS 10.0 web server:

                Open the IIS 10.0 Manager.

                Click the site name.'
            }

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
                },
                @{
                    Count = 2
                    CheckContent = 'Open the IIS 8.5 Manager.

                    Click the IIS 8.5 web server name.

                    Double-click the "ISAPI and CGI restrictions" icon.

                    Click “Edit Feature Settings".

                    Verify the "Allow unspecified CGI modules" and the "Allow unspecified ISAPI modules" check boxes are NOT checked.

                    If either or both of the "Allow unspecified CGI modules" and the "Allow unspecified ISAPI modules" check boxes are checked, this is a finding.'
                },
                @{
                    Count = 2
                    CheckContent = 'Open the IIS 8.5 Manager.

                    Click the IIS 8.5 web server name.

                    Double-click the "Machine Key" icon in the website Home Pane.

                    Verify "HMACSHA256" is selected for the Validation method and "Auto" is selected for the Encryption method.

                    If "HMACSHA256" is not selected for the Validation method and/or "Auto" is not selected for the Encryption method, this is a finding.'
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
