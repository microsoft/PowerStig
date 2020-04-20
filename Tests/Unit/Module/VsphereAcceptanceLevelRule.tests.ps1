#region Header
. $PSScriptRoot\.tests.header.ps1
#endregion

try
{
    InModuleScope -ModuleName "$($global:moduleName).Convert" {
        #region Test Setup
        $testRuleList = @(
            @{
                Level = 'PartnerSupported'
                OrganizationValueRequired = $false
                CheckContent = 'From the vSphere Web Client select the ESXi Host and go to Configure &gt;&gt; System &gt;&gt; Security Profile. Under "Host Image Profile Acceptance Level" view the acceptance level.

                or

                From a PowerCLI command prompt while connected to the ESXi host run the following commands:

                $esxcli = Get-EsxCli
                $esxcli.software.acceptance.get()

                If the acceptance level is CommunitySupported, this is a finding.'
                FixText = 'From the vSphere Web Client select the ESXi Host and go to Configure >> System >> Security Profile. Under "Host Image Profile Acceptance Level" click Edit… and use the pull-down selection, set the acceptance level to be VMwareCertified, VMwareAccepted, or PartnerSupported.

                or

                From a PowerCLI command prompt while connected to the ESXi host run the following commands:

                $esxcli = Get-EsxCli
                $esxcli.software.acceptance.Set("PartnerSupported")

                Note: VMwareCertified or VMwareAccepted may be substituted for PartnerSupported, depending upon local requirements.'
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
