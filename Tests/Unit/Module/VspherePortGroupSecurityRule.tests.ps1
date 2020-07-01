#region Header
. $PSScriptRoot\.tests.header.ps1
#endregion

try
{
    InModuleScope -ModuleName "$($global:moduleName).Convert" {
        #region Test Setup
        $testRuleList = @(
            @{
                OrganizationValueRequired = $false
                ForgedTransmitsInherited = '$true'
                CheckContent = 'From the vSphere Web Client go to Configure >> Networking >> Virtual Switches. View the properties on each virtual switch and port group and verify "Forged Transmits" is set to reject.

                or

                From a PowerCLI command prompt while connected to the ESXi host run the following commands:

                Get-VirtualPortGroup | Get-SecurityPolicy

                If the "Forged Transmits" policy is set to accept, this is a finding.'
                FixText = 'From the vSphere Web Client go to Configure >> Networking >> Virtual Switches. For each virtual switch and port group click Edit settings and change "Forged Transmits" to reject.

                or

                From a PowerCLI command prompt while connected to the ESXi host run the following commands:

                Get-VirtualPortGroup | Get-SecurityPolicy | Set-SecurityPolicy -ForgedTransmitsInherited $true'
            },
            @{
                OrganizationValueRequired = $false
                AllowPromiscuousInherited = '$true'
                CheckContent = 'From the vSphere Web Client go to Configure >> Networking >> Virtual Switches. View the properties on each virtual switch and port group and verify "Promiscuous Mode" is set to reject.

                or

                From a PowerCLI command prompt while connected to the ESXi host run the following commands:

                Get-VirtualPortGroup | Get-SecurityPolicy

                If the "Promiscuous Mode" policy is set to accept, this is a finding.'
                FixText = 'From the vSphere Web Client go to Configure >> Networking >> Virtual Switches. For each virtual switch and port group click Edit settings and change "Promiscuous Mode" to reject.

                or

                From a PowerCLI command prompt while connected to the ESXi host run the following commands:

                Get-VirtualPortGroup | Get-SecurityPolicy | Set-SecurityPolicy -AllowPromiscuousInherited $true'
            },
            @{
                OrganizationValueRequired = $false
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
        #endregion

        foreach ($testRule in $testRuleList)
        {
            . $PSScriptRoot\Convert.CommonTests.ps1
        }
    }
}
finally
{
    . $PSScriptRoot\.tests.footer.ps1
}
