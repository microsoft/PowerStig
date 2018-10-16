Configuration DotNetFramework_config
{
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $FrameworkVersion,

        [Parameter(Mandatory = $true)]
        [version]
        $stigVersion
    )

    Import-DscResource -ModuleName PowerStig

    Node localhost
    {
        DotNetFramework DotNetConfiguration
        {
            FrameworkVersion = $FrameworkVersion
            StigVersion      = $stigVersion
        }
    }
}
