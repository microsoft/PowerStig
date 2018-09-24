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
    
    Import-DscResource -ModuleName PowerStig -ModuleVersion 2.1.0.0
    Node localhost
    {
        IisServer ServerConfiguration
        {
            OsVersion   = $OsVersion
            StigVersion = $StigVersion
            LogPath     = $LogPath
        }
    }
}
