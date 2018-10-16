Configuration OracleJRE_config
{
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $configPath,

        [Parameter(Mandatory = $true)]
        [string]
        $propertiesPath,

        [Parameter(Mandatory = $true)]
        [string]
        $stigVersion
    )

    Import-DscResource -ModuleName PowerStig

    Node localhost
    {
        OracleJRE OracleConfiguration
        {
            ConfigPath     = $configPath
            PropertiesPath = $propertiesPath
            Stigversion    = $stigVersion
        }
    }
}
