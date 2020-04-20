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
            },
            @{
                OrganizationValueRequired = $false
                AllowPromiscuous = '$false'
                CheckContent = 'From the vSphere Web Client go to Configure >> Networking >> Virtual Switches. View the properties on each virtual switch and port group and verify "Promiscuous Mode" is set to reject.

                or

                From a PowerCLI command prompt while connected to the ESXi host run the following commands:

                Get-VirtualSwitch | Get-SecurityPolicy

                If the "Promiscuous Mode" policy is set to accept, this is a finding.'
                FixText = 'From the vSphere Web Client go to Configure >> Networking >> Virtual Switches. For each virtual switch and port group click Edit settings and change "Promiscuous Mode" to reject.

                or
                
                From a PowerCLI command prompt while connected to the ESXi host run the following commands:

                Get-VirtualSwitch | Get-SecurityPolicy | Set-SecurityPolicy -AllowPromiscuous $false'
            },
            @{
                OrganizationValueRequired = $false
                MacChanges = '$false'
                CheckContent = 'From the vSphere Web Client go to Configure >> Networking >> Virtual Switches. View the properties on each virtual switch and port group and verify "MAC Address Changes" is set to reject.

                or
                
                From a PowerCLI command prompt while connected to the ESXi host run the following commands:
                
                Get-VirtualSwitch | Get-SecurityPolicy

                If the "MAC Address Changes" policy is set to accept, this is a finding.'
                FixText = 'From the vSphere Web Client go to Configure >> Networking >> Virtual Switches. For each virtual switch and port group click Edit settings and change "MAC Address Changes" to reject.

                or
                
                From a PowerCLI command prompt while connected to the ESXi host run the following commands:
                
                Get-VirtualSwitch | Get-SecurityPolicy | Set-SecurityPolicy -MacChanges $false'
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
