Configuration IisSite_config
{
    param
    (
        [Parameter(Mandatory = $true)]
        [string[]]
        $WebAppPool,

        [Parameter(Mandatory = $true)]
        [string[]]
        $WebSiteName,

        [Parameter(Mandatory = $true)]
        [string]
        $osVersion,

        [Parameter(Mandatory = $true)]
        [string]
        $stigVersion
    )

    Import-DscResource -ModuleName PowerStig
    Node localhost
    {
        IisSite SiteConfiguration
        {
            WebAppPool  = $WebAppPool
            WebSiteName = $WebSiteName
            OsVersion   = $osVersion
            StigVersion = $stigVersion
        }
    }
}
