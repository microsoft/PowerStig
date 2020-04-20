#region Header
. $PSScriptRoot\.tests.header.ps1
#endregion

try
{
    InModuleScope -ModuleName "$($global:moduleName).Convert" {
        #region Test Setup
        $testRuleList = @(
            @{
                AdvancedSettings = "'DCUI.Access' = 'root'"
                OrganizationValueRequired = $false
                CheckContent = 'From the vSphere Web Client select the ESXi Host and go to Configure &gt;&gt; System &gt;&gt; Advanced System Settings.  Select the DCUI.Access value and verify only the root user is listed.

                or

                From a PowerCLI command prompt while connected to the ESXi host run the following command:
                
                Get-VMHost | Get-AdvancedSetting -Name DCUI.Access and verify it is set to root.
                
                If the DCUI.Access is not restricted to root, this is a finding.
                
                Note: This list is only for local user accounts and should only contain the root user.
                
                For environments that do not use vCenter server to manage ESXi, this is not applicable.'
            },
            @{
                AdvancedSettings = "'Security.AccountUnlockTime' = '900'"
                OrganizationValueRequired = $false
                CheckContent = 'From the vSphere Web Client select the ESXi Host and go to Configure &gt;&gt; System &gt;&gt; Advanced System Settings.  Select the Security.AccountUnlockTime value and verify it is set to 900.

                or

                From a PowerCLI command prompt while connected to the ESXi host run the following command:

                Get-VMHost | Get-AdvancedSetting -Name Security.AccountUnlockTime and verify it is set to 900.

                If the Security.AccountUnlockTime is set to a value other than 900, this is a finding.'
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
