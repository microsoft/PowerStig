#region Header
. $PSScriptRoot\.tests.header.ps1
#endregion

try
{
    InModuleScope -ModuleName "$($global:moduleName).Convert" {
        #region Test Setup
        $testRuleList = @(
            @{
                Key = 'TSM-SSH'
                Policy = 'off'
                Running = 'False'
                OrganizationValueRequired = $false
                CheckContent = 'From the vSphere Web Client select the ESXi Host and go to Configure >> System >> Security Profile. Under Services select Edit and view the "SSH" service and verify it is stopped.

                or

                From a PowerCLI command prompt while connected to the ESXi host run the following command:

                Get-VMHost | Get-VMHostService | Where {$_.Label -eq "SSH"}

                If the ESXi SSH service is running, this is a finding.'
            }
        )
        #endregion

        foreach ($testRule in $testRuleList)
        {
            . $PSScriptRoot\Convert.CommonTests.ps1
        }
    }
}
finally
{
    . $PSScriptRoot\.tests.footer.ps1
}
