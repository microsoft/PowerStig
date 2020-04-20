#region Header
. $PSScriptRoot\.tests.header.ps1
#endregion

try
{
    $stigRulesToTest = @(
        @{
            VirtualStandardSwitchGroup = @('Switch1','Switch2')
            ForgedTransmits = '$false'
            CheckContent = 'From the vSphere Web Client go to Configure >> Networking >> Virtual Switches. View the properties on each virtual switch and port group and verify "Forged Transmits" is set to reject.

            or

            From a PowerCLI command prompt while connected to the ESXi host run the following commands:

            Get-VirtualSwitch | Get-SecurityPolicy

            If the "Forged Transmits" policy is set to accept, this is a finding.'
            FixText = 'From the vSphere Web Client go to Configure >> Networking >> Virtual Switches. For each virtual switch and port group click Edit settings and change "Forged Transmits" to reject.

            or

            From a PowerCLI command prompt while connected to the ESXi host run the following commands:

            Get-VirtualSwitch | Get-SecurityPolicy | Set-SecurityPolicy -ForgedTransmits $false'
        }
    )

    Describe 'VsphereVssSecurity Rule Conversion' {

        foreach ( $stig in $stigRulesToTest )
        {
            Context "VsphereVssSecurity '$($stig.ForgedTransmits)'" {

                [xml] $StigRule = Get-TestStigRule -Checkcontent $stig.CheckContent -FixText $stig.FixText -XccdfTitle 'Vsphere'
                $TestFile = Join-Path -Path $TestDrive -ChildPath 'TextData.xml'
                $StigRule.Save($TestFile)
                $rule = ConvertFrom-StigXccdf -Path $TestFile

                It 'Should return an VsphereVssSecurityRule Object' {
                    $rule.GetType() | Should Be 'VsphereVssSecurityRule'
                }
                It "Should return Key '$($stig.ForgedTransmits)'" {
                    $rule.ForgedTransmits | Should Be $stig.ForgedTransmits
                }
                It 'Should set the correct DscResource' {
                    $rule.DscResource | Should Be 'VMHostVssSecurity'
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
