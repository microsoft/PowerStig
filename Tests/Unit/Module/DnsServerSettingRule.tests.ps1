#region Header
. $PSScriptRoot\.tests.header.ps1
#endregion

try
{
    InModuleScope -ModuleName "$($global:moduleName).Convert" {
        #region Test Setup
        $testRuleList = @(
            @{
                PropertyName = 'EventLogLevel'
                PropertyValue = '4'
                OrganizationValueRequired = $false
                CheckContent = 'Log on to the DNS server using the Domain Admin or Enterprise Admin account.

                Press Windows Key + R, execute dnsmgmt.msc.

                Right-click the DNS server, select “Properties”.

                Click on the “Event Logging” tab. By default, all events are logged.

                Verify "Errors and warnings" or "All events" is selected.

                If any option other than "Errors and warnings" or "All events" is selected, this is a finding.'
            }
            @{
                IsExistingRule = $True
                PropertyName = 'NoRecursion'
                PropertyValue = '$True'
                OrganizationValueRequired = $false
                CheckContent = 'Note: If the Windows DNS server is in the classified network, this check is Not Applicable.

                Note: In Windows DNS Server, if forwarders are configured, the recursion setting must also be enabled since disabling recursion will disable forwarders.

                If forwarders are not used, recursion must be disabled. In both cases, the use of root hints must be disabled.

                Log on to the DNS server using the Domain Admin or Enterprise Admin account.

                Press Windows Key + R, execute dnsmgmt.msc.

                On the opened DNS Manager snap-in from the left pane, right-click on the server name for the DNS server and select “Properties”.

                Click on the “Forwarders” tab.

                If forwarders are not being used, this is not applicable.

                Review the IP address(es) for the forwarder(s) use.

                If the DNS Server does not forward to another DoD-managed DNS server or to the DoD Enterprise Recursive Services (ERS), this is a finding.

                If the "Use root hints if no forwarders are available" is selected, this is a finding.'
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
