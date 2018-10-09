Configuration OracleJRE_config
{
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $ConfigPath,

        [Parameter(Mandatory = $true)]
        [string]
        $PropertiesPath,

        [Parameter(Mandatory = $true)]
        [string]
        $StigVersion
    )

    Import-DscResource -ModuleName PowerStig

    Node localhost
    {
        OracleJRE OracleConfiguration
        {
            ConfigPath     = $ConfigPath
            PropertiesPath = $PropertiesPath
            Stigversion    = $StigVersion
        }
    }
}
