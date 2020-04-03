#region Header
. $PSScriptRoot\.tests.header.ps1
$setDynamicClassFileParams = @{
    ClassModuleFileName = 'WinEventLogRule.Convert.psm1'
    PowerStigBuildPath  = $script:moduleRoot
    DestinationPath     = (Join-Path -Path $PSScriptRoot -ChildPath '..\.DynamicClassImport\WinEventLogRule.Convert.ps1')
}
Set-DynamicClassFile @setDynamicClassFileParams
. $setDynamicClassFileParams.DestinationPath
#endregion

try
{
    InModuleScope -ModuleName "$($global:moduleName).Convert" {
        #region Test Setup
        $testRuleList = @(
            @{
                LogName = 'Microsoft-Windows-DnsServer/Analytical'
                IsEnabled = 'True'
                OrganizationValueRequired = $false
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

        foreach ($testRule in $testRuleList)
        {
            . $PSScriptRoot\Convert.CommonTests.ps1
        }

        #region Add Custom Tests Here

        #endregion
    }
}
finally
{
    . $PSScriptRoot\.tests.footer.ps1
}
