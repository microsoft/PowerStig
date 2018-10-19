Configuration WindowsDnsServer_config
{
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $OsVersion,

        [Parameter(Mandatory = $true)]
        [version]
        $StigVersion,

        [Parameter(Mandatory = $true)]
        [string]
        $ForestName,

        [Parameter(Mandatory = $true)]
        [string]
        $DomainName
    )

    Import-DscResource -ModuleName PowerStig

    Node localhost
    {
        WindowsDnsServer BaseLineSettings
        {
            OsVersion   = $osVersion
            StigVersion = $stigVersion
            ForestName  = $forestName
            DomainName  = $domainName
        }
    }
}
