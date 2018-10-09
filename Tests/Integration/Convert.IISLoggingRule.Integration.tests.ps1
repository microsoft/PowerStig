#region Header
. $PSScriptRoot\.tests.header.ps1
#endregion
try
{
    #region Test Setup
    $stigRulesToTest = @(
        @{
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
            )
            StigTitle           = 'IIS 8.5 Site Security Technical Implementation Guide'
            LogFlags            = 'UserAgent,UserName,Referer'
            LogFormat           = 'W3C'
            LogPeriod           = $null
            LogTargetW3C        = $null
            dscresource         = 'xWebsite'
            CheckContent        = 'Follow the procedures below for each site hosted on the IIS 8.5 web server:

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
        @{
            LogCustomFieldEntry = @(
                @{
                    SourceType = 'ServerVariable'
                    SourceName = 'HTTP_USER_AGENT'
                }
                @{
                    SourceType = 'RequestHeader'
                    SourceName = 'User-Agent'
                }
            )
            StigTitle           = 'IIS 8.5 Server Security Technical Implementation Guide'
            LogFlags            = $null
            LogFormat           = 'W3C'
            LogPeriod           = $null
            LogTargetW3C        = $null
            dscresource         = 'xIisLogging'
            CheckContent        = 'Access the IIS 8.5 web server IIS Manager.

                Click the IIS 8.5 web server name.

                Under "IIS", double-click the "Logging" icon.

                Verify the "Format:" under "Log File" is configured to "W3C".

                Select the "Fields" button. Under "Custom Fields", verify the following fields have been configured:

                Request Header >> Connection

                Request Header >> Warning

                If any of the above fields are not selected, this is a finding.'
        }
    )
    #endregion
    #region Tests
    Describe "IisLogging Rule Conversion" {

        foreach ($stig in $stigRulesToTest)
        {
            [xml] $StigRule = Get-TestStigRule -CheckContent $stig.CheckContent -XccdfTitle $stig.StigTitle
            $TestFile = Join-Path -Path $TestDrive -ChildPath 'TextData.xml'
            $StigRule.Save( $TestFile )
            $rule = ConvertFrom-StigXccdf -Path $TestFile

            It "Should return an IisLoggingRule Object" {
                $rule.GetType() | Should Be 'IisLoggingRule'
            }

            It "Should return expected LogCustomFieldEntry" {
                $compare = Compare-Object -ReferenceObject  $rule.LogCustomFieldEntry -DifferenceObject $stig.LogCustomFieldEntry
                $compare.count | Should Be 0
            }

            It "Should return LogFlags '$($stig.LogFlags)'" {
                $rule.LogFlags | Should Be $stig.LogFlags
            }

            It "Should return LogFormat '$($stig.LogFormat)'" {
                $rule.LogFormat | Should Be $stig.LogFormat
            }

            It "Should return LogPeriod '$($stig.LogPeriod)'" {
                $rule.LogPeriod | Should Be $stig.LogPeriod
            }

            It "Should return LogTargetW3C '$($stig.LogTargetW3C)'" {
                $rule.LogTargetW3C | Should Be $stig.LogTargetW3C
            }

            It 'Should set status to pass' {
                $rule.ConversionStatus | Should Be 'pass'
            }

            It 'Should set dscresource to the correct value' {
                $rule.Dscresource | Should Be $stig.Dscresource
            }
        }
    }
    #endregion
}
finally
{
    . $PSScriptRoot\.tests.footer.ps1
}
