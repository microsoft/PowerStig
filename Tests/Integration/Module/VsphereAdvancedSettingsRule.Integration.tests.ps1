#region Header
. $PSScriptRoot\.tests.header.ps1
#endregion

try
{
    $stigRulesToTest = @(
        @{
            AdvancedSettings = "'DCUI.Access' = 'root'"
            CheckContent = 'From the vSphere Web Client select the ESXi Host and go to Configure >> System >> Advanced System Settings. Select the DCUI.Access value and verify only the root user is listed.

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
        }
        @{
            AdvancedSettings = "'UserVars.ESXiShellInteractiveTimeOut' = '600'"
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

    Describe 'VsphereAdvancedSettings Rule Conversion' {

        foreach ($stig in $stigRulesToTest)
        {
            Context "VsphereAdvancedSettings '$($stig.AdvancedSettings)'" {

                [xml] $stigRule = Get-TestStigRule -Checkcontent $stig.CheckContent -FixText $stig.FixText -XccdfTitle 'Vsphere'
                $testFile = Join-Path -Path $TestDrive -ChildPath 'TextData.xml'
                $stigRule.Save($testFile)
                $rule = ConvertFrom-StigXccdf -Path $testFile

                It 'Should return an VsphereAdvancedSettingsRule Object' {
                    $rule.GetType() | Should -Be 'VsphereAdvancedSettingsRule'
                }

                It "Should return Value '$($stig.AdvancedSettings)'" {
                    $rule.AdvancedSettings | Should -Be $stig.AdvancedSettings
                }

                It 'Should set the correct DscResource' {
                    $rule.DscResource | Should -Be 'VMHostAdvancedSettings'
                }

                It 'Should Set the status to pass' {
                    $rule.ConversionStatus | Should -Be 'pass'
                }
            }
        }
    }
}

finally
{
    . $PSScriptRoot\.tests.footer.ps1
}
