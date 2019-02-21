#region Header
using module .\..\..\..\Module\Rule.DnsServerRootHint\Convert\DnsServerRootHintRule.Convert.psm1
. $PSScriptRoot\.tests.header.ps1
#endregion

try
{
    InModuleScope -ModuleName "$($global:moduleName).Convert" {
        #region Test Setup
        $testRuleList = @(
            @{
                HostName = '$null'
                IpAddress = '$null'
                OrganizationValueRequired = $false
                CheckContent = 'Log on to the authoritative DNS server using the Domain Admin or Enterprise Admin account.

                Press Windows Key + R, execute dnsmgmt.msc.

                Right-click the DNS server, select “Properties”.

                Select the "Root Hints" tab.

                Verify the "Root Hints" is either empty or only has entries for internal zones under "Name servers:". All Internet root server entries must be removed.

                If "Root Hints" is not empty and the entries on the "Root Hints" tab under "Name servers:" are external to the local network, this is a finding.'
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
