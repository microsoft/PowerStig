#region Header
. $PSScriptRoot\.tests.header.ps1
#endregion

try
{
    InModuleScope -ModuleName "$($global:moduleName).Convert" {
        #region Test Setup
        $testRuleList = @(
            @{
                LogFlags = 'Date,Time,ClientIP,UserName,Method,UriQuery,HttpStatus,Referer'
                LogFormat = $null
                LogPeriod = $null
                LogTargetW3C = $null
                LogCustomFieldEntry = $null
                OrganizationValueRequired = $false
                CheckContent = 'Follow the procedures below for each site hosted on the IIS 8.5 web server:

            Open the IIS 8.5 Manager.

            Click the site name.

            Click the "Logging" icon.

            Under Format select "W3C".

            Click Select Fields, verify at a minimum the following fields are checked: Date, Time, Client IP Address, User Name, Method, URI Query, Protocol Status, and Referrer.

            If the "W3C" is not selected as the logging format OR any of the required fields are not selected, this is a finding.'
            },
            @{
                LogFlags = $null
                LogFormat = $null
                LogPeriod = $null
                LogTargetW3C = 'File,ETW'
                LogCustomFieldEntry = $null
                OrganizationValueRequired = $false
                CheckContent = 'Follow the procedures below for each site hosted on the IIS 8.5 web server:

              Open the IIS 8.5 Manager.

              Click the site name.

              Click the "Logging" icon.

              Under Log Event Destination, verify the "Both log file and ETW event" radio button is selected.

              If the "Both log file and ETW event" radio button is not selected, this is a finding.'
            }
        )
        #endregion

        foreach ($testRule in $testRuleList)
        {
            . $PSScriptRoot\Convert.CommonTests.ps1
        }

        #region Add Custom Tests Here

        # Testing a complex retun object
        Describe 'Complex Rule' {

            $testRule = @{
                LogFlags = 'UserAgent,UserName,Referer'
                LogFormat = 'W3C'
                LogPeriod = $null
                LogTargetW3C = $null
                LogCustomFieldEntry = @(
                    @{
                        SourceType = 'ServerVariable'
                        SourceName = 'HTTP_USER_AGENT'
                    }
                    @{
                        SourceType = 'RequestHeader'
                        SourceName = 'User-Agent'
                    }
                    @{
                        SourceType = 'RequestHeader'
                        SourceName = 'Authorization'
                    }
                    @{
                        SourceType = 'ResponseHeader'
                        SourceName = 'Content-Type'
                    }
                ) | ConvertTo-Json
                OrganizationValueRequired = $false
                CheckContent = 'Follow the procedures below for each site hosted on the IIS 8.5 web server:

                Access the IIS 8.5 web server IIS 8.5 Manager.

                Under "IIS", double-click the "Logging" icon.

                Verify the "Format:" under "Log File" is configured to "W3C".

                Select the "Fields" button.

                Under "Standard Fields", verify "User Agent", "User Name" and "Referrer" are selected.

                Under "Custom Fields", verify the following fields have been configured:

                Server Variable >> HTTP_USER_AGENT

                Request Header >> User-Agent

                Request Header >> Authorization

                Response Header >> Content-Type

                If any of the above fields are not selected, this is a finding.'
            }

            It 'Should extract a complex LogCustomFieldEntry' {
                $stigRule = Get-TestStigRule -CheckContent $testRule.checkContent -ReturnGroupOnly
                $convertedRule = [IISLoggingRuleConvert]::new($stigRule)
                $convertedRule.LogCustomFieldEntry | ConvertTo-Json | Should -Be $testRule.LogCustomFieldEntry
            }
        }
        #endregion
    }
}
finally
{
    . $PSScriptRoot\.tests.footer.ps1
}
