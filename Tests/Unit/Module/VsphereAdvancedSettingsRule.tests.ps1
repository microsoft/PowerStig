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
                FixText = 'From the vSphere Web Client select the ESXi Host and go to Configure >> System >> Advanced System Settings. Click Edit and select the DCUI.Access value and configure it to root.

                or

                From a PowerCLI command prompt while connected to the ESXi host run the following command:

                Get-VMHost | Get-AdvancedSetting -Name DCUI.Access | Set-AdvancedSetting -Value "root"'
            },
            @{
                AdvancedSettings = "'UserVars.ESXiShellInteractiveTimeOut' = '600'"
                OrganizationValueRequired = $false
                CheckContent = 'From the vSphere Web Client select the ESXi Host and go to Configure >> System >> Advanced System Settings. Select the UserVars.ESXiShellInteractiveTimeOut value and verify it is set to 600 (10 Minutes).

                or

                From a PowerCLI command prompt while connected to the ESXi host run the following command:

                Get-VMHost | Get-AdvancedSetting -Name UserVars.ESXiShellInteractiveTimeOut

                If the UserVars.ESXiShellInteractiveTimeOut setting is not set to 600, this is a finding.'
                FixText = 'From the vSphere Web Client select the ESXi Host and go to Configure >> System >> Advanced System Settings. Click Edit and select the UserVars.ESXiShellInteractiveTimeOut value and configure it to 600.

                or

                From a PowerCLI command prompt while connected to the ESXi host run the following commands:

                Get-VMHost | Get-AdvancedSetting -Name UserVars.ESXiShellInteractiveTimeOut | Set-AdvancedSetting -Value 600'
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
