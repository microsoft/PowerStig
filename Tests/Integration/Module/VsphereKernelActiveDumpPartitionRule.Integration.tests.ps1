#region Header
. $PSScriptRoot\.tests.header.ps1
#endregion

try
{
    $stigRulesToTest = @(
        @{
            Enabled = '$true'
            CheckContent = 'From the vSphere Web Client select the ESXi Host and right click. If the "Add Diagnostic Partition" option is greyed out then core dumps are configured.

            or
            
            From a PowerCLI command prompt while connected to the ESXi host run the following commands:
            
            $esxcli = Get-EsxCli
            $esxcli.system.coredump.partition.get()
            $esxcli.system.coredump.network.get()
            
            The first command prepares for the other two. The second command shows whether there is an active core dump partition configured. The third command shows whether a network core dump collector is configured and enabled, via the "HostVNic", "NetworkServerIP", "NetworkServerPort", and "Enabled" variables. 
            
            If there is no active core dump partition or the network core dump collector is not configured and enabled, this is a finding.'
            FixText  = 'From the vSphere Web Client select the ESXi Host and right click. Select the "Add Diagnostic Partition" option configure a core dump diagnostic partition.

            or
            
            From a PowerCLI command prompt while connected to the ESXi host run at least one of the following sets of commands:
            
            To configure a core dump partition:
            
            $esxcli = Get-EsxCli
            #View available partitions to configure
            $esxcli.system.coredump.partition.list()
            $esxcli.system.coredump.partition.set($null,"PartitionName",$null,$null)
            
            To configure a core dump collector:
            
            $esxcli = Get-EsxCli
            $esxcli.system.coredump.network.set($null,"vmkernel port to use",$null,"CollectorIP","CollectorPort")
            $esxcli.system.coredump.network.set($true)
            '
        }
    )

    Describe 'VsphereKernelActiveDumpPartition Rule Conversion' {

        foreach ( $stig in $stigRulesToTest )
        {
            Context "VsphereKernelActiveDumpPartition '$($stig.Enabled)'" {

                [xml] $StigRule = Get-TestStigRule -Checkcontent $stig.CheckContent -FixText $stig.FixText -XccdfTitle 'Vsphere'
                $TestFile = Join-Path -Path $TestDrive -ChildPath 'TextData.xml'
                $StigRule.Save($TestFile)
                $rule = ConvertFrom-StigXccdf -Path $TestFile

                It 'Should return an VsphereKernelActiveDumpPartitionRule Object' {
                    $rule.GetType() | Should Be 'VsphereKernelActiveDumpPartitionRule'
                }
                It "Should return Value '$($stig.Enabled)'" {
                    $rule.Level | Should Be $stig.Level
                }
                It 'Should set the correct DscResource' {
                    $rule.DscResource | Should Be 'VMHostKernelActiveDumpPartition'
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
