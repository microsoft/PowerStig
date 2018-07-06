#region HEADER
. $PSScriptRoot\.Convert.Test.Header.ps1
#endregion
#region Test Setup
$checkContent = 'Log on to the DNS server using the Domain Admin or Enterprise Admin account.

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
#endregion
#region Tests
try 
{
    Describe "ConvertTo-DnsWinEventLogRule" {
        <#
            This function can't really be unit tested, since the call cannot be mocked by pester, so
            the only thing we can really do at this point is to verify that it returns the correct object.
        #>
        $stigRule = Get-TestStigRule -CheckContent $checkContent -ReturnGroupOnly
        $rule = ConvertTo-WinEventLogRule -StigRule $stigRule

        It "Should return an WinEventLogRule object" {
            $rule.GetType() | Should Be 'WinEventLogRule'
        }
    }
}
catch
{
    Remove-Variable STIGSettings -Scope Global
}
#endregion Tests
