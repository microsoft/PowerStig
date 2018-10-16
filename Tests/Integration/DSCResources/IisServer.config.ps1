Configuration IisServer_Config
{
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $osVersion,
        
        [Parameter(Mandatory = $true)]
        [string]
        $stigVersion,
        
        [Parameter(Mandatory = $true)]
        [string]
        $LogPath
    )
    
    Import-DscResource -ModuleName PowerStig
    Node localhost
    {
        IisServer ServerConfiguration
        {
            OsVersion   = $osVersion
            StigVersion = $stigVersion
            LogPath     = $LogPath
        }
    }
}
