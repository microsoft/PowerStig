#region Header
. $PSScriptRoot\.tests.header.ps1
#endregion

$testCases = @(
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

try
{
    Describe 'VsphereVssSecurity Rule Conversion' {

        Context 'When VsphereVssSecurity is converted' {

            It 'Should return a correctly converted "<ForgedTransmits>" Rule' -TestCases $testCases {
                param ($VirtualStandardSwitchGroup, $ForgedTransmits, $CheckContent, $FixText)

                [xml] $stigRule = Get-TestStigRule -Checkcontent $CheckContent -FixText $FixText -XccdfTitle 'Vsphere'
                $testFile = Join-Path -Path $TestDrive -ChildPath 'TextData.xml'
                $stigRule.Save($testFile)
                $rule = ConvertFrom-StigXccdf -Path $testFile

                $rule.GetType().Name   | Should -Be 'VsphereVssSecurityRule'
                $rule.ForgedTransmits  | Should -Be $ForgedTransmits
                $rule.DscResource      | Should -Be 'VMHostVssSecurity'
                $rule.ConversionStatus | Should -Be 'pass'
            }
        }
    }
}

finally
{
    . $PSScriptRoot\.tests.footer.ps1
}
