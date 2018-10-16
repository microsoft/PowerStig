#region Header
. $PSScriptRoot\.tests.header.ps1
#endregion
try
{
    #region Test Setup
    $EventsToTest = @(
        @{
            LogName      = 'Microsoft-Windows-DnsServer/Analytical'
            IsEnabled    = 'True'
            CheckContent = 'Log on to the DNS server using the Domain Admin or Enterprise Admin account.
            
            Press Windows Key + R, execute dnsmgmt.msc.
            
            Right-click the DNS server, select Properties.
            
            Click on the Event Logging tab. By default, all events are logged.
            
            Verify "Errors and warnings" or "All events" is selected.
            
            If any option other than "Errors and warnings" or "All events" is selected, this is a finding.
            
            Log on to the DNS server using the Domain Admin or Enterprise Admin account.
            
            Open an elevated Windows PowerShell prompt on a DNS server using the Domain Admin or Enterprise Admin account.
            
            Use the Get-DnsServerDiagnostics cmdlet to view the status of individual diagnostic events.
            
            All diagnostic events should be set to "True".
            
            If all diagnostic events are not set to "True", this is a finding.
            
            For Windows 2012 R2 DNS Server, the Enhanced DNS logging and diagnostics in Windows Server 2012 R2 must also be enabled.
            
            Run eventvwr.msc at an elevated command prompt. 
            
            In the Event viewer, navigate to the applications and Services Logs\Microsoft\Windows\DNS Server.
            
            Right-click DNS Server, point to View, and then click "Show Analytic and Debug Logs".
            
            Right-click Analytical and then click on Properties.
            Confirm the "Enable logging" check box is selected.
            
            If the check box to enable analytic and debug logs is not enabled on a Windows 2012 R2 DNS server, this is a finding.'
        }
    )
    #endregion
    #region Tests
    Describe "DnsWinEventLog Rule Conversion" {

        foreach ( $WinEvents in $EventsToTest)
        {
            Context "DnsWinEventLog '$($WinEvents.LogName)'" {

                [xml] $stigRule = Get-TestStigRule -CheckContent $WinEvents.CheckContent -XccdfTitle 'DNS'
                $TestFile = Join-Path -Path $TestDrive -ChildPath 'TextData.xml'
                $stigRule.Save( $TestFile )
                $rule = ConvertFrom-StigXccdf -Path $TestFile

                It "Should return an WinEventLogRule Object" {
                    $rule.GetType() | Should Be 'WinEventLogRule'
                }
                It "Should return LogName '$($WinEvents.LogName)'" {
                    $rule.LogName | Should Be $WinEvents.LogName
                } 
                It "Should return IsEnabled '$($WinEvents.IsEnabled)'" {
                    $rule.IsEnabled | Should Be $WinEvents.IsEnabled
                }
                It 'Should Set the status to pass' {
                    $rule.conversionstatus | Should Be 'pass'
                }
            }
        }
    }
    #endregion
}
finally
{
    . $PSScriptRoot\.tests.footer.ps1
}
