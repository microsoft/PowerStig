Configuration WindowsFirewall_config
{
    param
    (
        [Parameter(Mandatory = $true)]
        [version]
        $stigVersion
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
