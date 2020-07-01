#region Header
. $PSScriptRoot\.tests.header.ps1
#endregion

$testCases = @(
    @{
        VmGroup = @('VM1','VM2')
        MacChangesInherited = '$true'
        CheckContent = 'From the vSphere Web Client go to Configure >> Networking >> Virtual Switches. View the properties on each virtual switch and port group and verify "MAC Address Changes" is set to reject.

        or

        From a PowerCLI command prompt while connected to the ESXi host run the following commands:

        Get-VirtualPortGroup | Get-SecurityPolicy

        If the "MAC Address Changes" policy is set to accept, this is a finding.'
        FixText = 'From the vSphere Web Client go to Configure >> Networking >> Virtual Switches. For each virtual switch and port group click Edit settings and change "MAC Address Changes" to reject.

        or

        From a PowerCLI command prompt while connected to the ESXi host run the following commands:

        Get-VirtualPortGroup | Get-SecurityPolicy | Set-SecurityPolicy -MacChangesInherited $true'

    }
)

try
{
    Describe 'VspherePortGroupSecurity Rule Conversion' {

        Context 'When VspherePortGroupSecurity is converted' {

            It 'Should return a correctly converted "<MacChangesInherited>" Rule' -TestCases $testCases {
                param ($VmGroup, $MacChangesInherited, $CheckContent, $FixText)

                [xml] $stigRule = Get-TestStigRule -Checkcontent $CheckContent -FixText $FixText -XccdfTitle 'Vsphere'
                $testFile = Join-Path -Path $TestDrive -ChildPath 'TextData.xml'
                $stigRule.Save($testFile)
                $rule = ConvertFrom-StigXccdf -Path $testFile

                $rule.GetType().Name      | Should -Be 'VspherePortGroupSecurityRule'
                $rule.MacChangesInherited | Should -Be $MacChangesInherited
                $rule.DscResource         | Should -Be 'VMHostVssPortGroupSecurity'
                $rule.ConversionStatus    | Should -Be 'pass'
            }
        }
    }
}

finally
{
    . $PSScriptRoot\.tests.footer.ps1
}
