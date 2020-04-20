#region Header
. $PSScriptRoot\.tests.header.ps1
#endregion

try
{
    InModuleScope -ModuleName "$($global:moduleName).Convert" {
        #region Test Setup
        $testRuleList = @(
            @{
                NtpServer = $null
                OrganizationValueRequired = $true
                OrganizationValueTestString = "{0} is set to a string array of authoritative DoD time sources"
                CheckContent = 'From the vSphere Web Client select the ESXi Host and go to Configure &gt;&gt; System &gt;&gt; Time Configuration. Click Edit to verify the configured NTP servers and service startup policy.

                or

                From a PowerCLI command prompt while connected to the ESXi host run the following command:

                Get-VMHost | Get-VMHostNTPServer

                If the NTP service is not configured with authoritative DoD time sources and the service is not configured to start and stop with the host and is running, this is a finding.'
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
