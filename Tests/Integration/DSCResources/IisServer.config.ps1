Configuration IisServer_Config
{
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $OsVersion,

        [Parameter(Mandatory = $true)]
        [string]
        $StigVersion,

        [Parameter(Mandatory = $true)]
        [string]
        $LogPath
    )

    Import-DscResource -ModuleName PowerStig
    Node localhost
    {
        IisServer ServerConfiguration
        {
            OsVersion   = $OsVersion
            StigVersion = $stigVersion
            LogPath     = $LogPath
        }
    }
}
