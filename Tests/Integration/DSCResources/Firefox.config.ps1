Configuration Firefox_config
{
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $stigVersion
    )

    Import-DscResource -ModuleName PowerStig

    Node localhost
    {
        Firefox FirefoxConfiguration
        {
            Stigversion = $stigVersion
        }
    }
}
