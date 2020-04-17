configuration Vsphere_config
{
    param
    (
        [Parameter()]
        [string]
        $Version,

        [Parameter()]
        [string]
        $HostIP,

        [Parameter()]
        [string]
        $ServerIP,

        [Parameter()]
        [PSCredential]
        $Credential,

        [Parameter()]
        [string[]]
        $VirtualStandardSwitchGroup,

        [Parameter()]
        [string[]]
        $VmGroup
    )

    Import-DscResource -ModuleName PowerStig

    Node localhost
    {
        Vsphere BaseLineSettings
        {
            Version = '6.5'
            HostIP = '10.10.10.10'
            ServerIP = '10.10.10.12'
            Credential = $credential
            VirtualStandardSwitchGroup = @('Switch1','Switch2')
            VmGroup = @('Vm1','Vm2')

        }
    }
}
