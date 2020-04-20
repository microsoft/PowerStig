#region Header
. $PSScriptRoot\.tests.header.ps1
#endregion

try
{
    $stigRulesToTest = @(
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

    Describe 'VspherePortGroupSecurity Rule Conversion' {

        foreach ( $stig in $stigRulesToTest )
        {
            Context "VspherePortGroupSecurity '$($stig.MacChangesInherited)'" {

                [xml] $StigRule = Get-TestStigRule -Checkcontent $stig.CheckContent -FixText $stig.FixText -XccdfTitle 'Vsphere'
                $TestFile = Join-Path -Path $TestDrive -ChildPath 'TextData.xml'
                $StigRule.Save($TestFile)
                $rule = ConvertFrom-StigXccdf -Path $TestFile

                It 'Should return an VspherePortGroupSecurityRule Object' {
                    $rule.GetType() | Should Be 'VspherePortGroupSecurityRule'
                }
                It "Should return Key '$($stig.MacChangesInherited)'" {
                    $rule.MacChangesInherited | Should Be $stig.MacChangesInherited
                }
                It 'Should set the correct DscResource' {
                    $rule.DscResource | Should Be 'VMHostVssPortGroupSecurity'
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
