Configuration WindowsFirewall_config
{
    param
    (
        [Parameter(Mandatory = $true)]
        [version]
        $StigVersion
    )

    Import-DscResource -ModuleName PowerStig

    Node localhost
    {
        WindowsFirewall BaseLineSettings
        {
            StigVersion = $stigVersion
        }
    }
}
