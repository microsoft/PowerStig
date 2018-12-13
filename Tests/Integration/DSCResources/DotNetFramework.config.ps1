Configuration DotNetFramework_config
{
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $FrameworkVersion,

        [Parameter(Mandatory = $true)]
        [version]
        $StigVersion
    )

    Import-DscResource -ModuleName PowerStig -moduleversion 2.3.1.0

    Node localhost
    {
        DotNetFramework DotNetConfiguration
        {
            FrameworkVersion = $FrameworkVersion
            StigVersion      = $StigVersion
        }
    }
}
