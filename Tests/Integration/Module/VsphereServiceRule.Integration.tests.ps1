#region Header
. $PSScriptRoot\.tests.header.ps1
#endregion

try
{
    $stigRulesToTest = @(
        @{
            Key = 'TSM-SSH'
            Policy = 'off'
            Running = 'False'
            CheckContent = 'From the vSphere Web Client select the ESXi Host and go to Configure >> System >> Security Profile. Under Services select Edit and view the "SSH" service and verify it is stopped.

            or

            From a PowerCLI command prompt while connected to the ESXi host run the following command:

            Get-VMHost | Get-VMHostService | Where {$_.Label -eq "SSH"}

            If the ESXi SSH service is running, this is a finding.'
        }
    )

    Describe 'VsphereService Rule Conversion' {

        foreach ($stig in $stigRulesToTest)
        {
            Context "VsphereService '$($stig.Key)'" {

                [xml] $stigRule = Get-TestStigRule -Checkcontent $stig.CheckContent -FixText $stig.FixText -XccdfTitle 'Vsphere'
                $testFile = Join-Path -Path $TestDrive -ChildPath 'TextData.xml'
                $stigRule.Save($testFile)
                $rule = ConvertFrom-StigXccdf -Path $testFile

                It 'Should return an VsphereServiceRule Object' {
                    $rule.GetType() | Should Be 'VsphereServiceRule'
                }

                It "Should return Key '$($stig.Key)'" {
                    $rule.Level | Should Be $stig.Level
                }

                It "Should return Policy '$($stig.Policy)'" {
                    $rule.Policy | Should Be $stig.Policy
                }

                It "Should return Running '$($stig.Running)'" {
                    $rule.Running | Should Be $stig.Running
                }

                It 'Should set the correct DscResource' {
                    $rule.DscResource | Should Be 'VMHostService'
                }

                It 'Should Set the status to pass' {
                    $rule.ConversionStatus | Should Be 'pass'
                }
            }
        }
    }
}

finally
{
    . $PSScriptRoot\.tests.footer.ps1
}
