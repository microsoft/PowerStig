#region Header
. $PSScriptRoot\.tests.header.ps1
#endregion

try
{
    InModuleScope -ModuleName "$($global:moduleName).Convert" {
        #region Test Setup
        $testRuleList = @(
            @{
                Enabled = '$true'
                OrganizationValueRequired = $false
                CheckContent = 'From the vSphere Web Client select the ESXi Host and right click. If the "Add Diagnostic Partition" option is greyed out then core dumps are configured.

                or

                From a PowerCLI command prompt while connected to the ESXi host run the following commands:

                $esxcli = Get-EsxCli
                $esxcli.system.coredump.partition.get()
                $esxcli.system.coredump.network.get()

                The first command prepares for the other two. The second command shows whether there is an active core dump partition configured. The third command shows whether a network core dump collector is configured and enabled, via the "HostVNic", "NetworkServerIP", "NetworkServerPort", and "Enabled" variables. 

                If there is no active core dump partition or the network core dump collector is not configured and enabled, this is a finding.'
                FixText = 'From the vSphere Web Client select the ESXi Host and right click. Select the "Add Diagnostic Partition" option configure a core dump diagnostic partition.

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
                $esxcli.system.coredump.network.set($true)'
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
