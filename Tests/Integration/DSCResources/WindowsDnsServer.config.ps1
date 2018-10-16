Configuration WindowsDnsServer_config
{
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $osVersion,

        [Parameter(Mandatory = $true)]
        [version]
        $stigVersion,

        [Parameter(Mandatory = $true)]
        [string]
        $forestName,

        [Parameter(Mandatory = $true)]
        [string]
        $domainName
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
