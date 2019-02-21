#region Header
using module .\..\..\..\Module\Rule.DnsServerSetting\Convert\DnsServerSettingRule.Convert.psm1
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
        )
        #endregion

        Foreach ($testRule in $testRuleList)
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
