Configuration IisSite_config
{
    param
    (

        [Parameter(Mandatory = $true)]
        [string]
        $StigVersion,

        [Parameter()]
        [string[]]
        $SkipRule,

        [Parameter()]
        [string[]]
        $SkipRuleType,

        [Parameter()]
        [string[]]
        $Exception,

        [Parameter()]
        [string[]]
        $OrgSettings,
        ### Begin DO NOT REMOVE Required for Consolidated Integration Tests
        [Parameter()]
        [string]
        [AllowNull()]
        $BrowserVersion,

        [Parameter()]
        [string[]]
        [AllowNull()]
        $OfficeApp,

        [Parameter()]
        [string]
        [AllowNull()]
        $ConfigPath,

        [Parameter()]
        [string]
        [AllowNull()]
        $PropertiesPath,

        [Parameter()]
        [string]
        [AllowNull()]
        $SqlVersion,

        [Parameter()]
        [string]
        [AllowNull()]
        $SqlRole,

        [Parameter()]
        [string]
        [AllowNull()]
        $ForestName,

        [Parameter()]
        [string]
        [AllowNull()]
        $DomainName,

        [Parameter()]
        [string]
        [AllowNull()]
        $OsVersion,

        [Parameter()]
        [string]
        [AllowNull()]
        $OsRole,

        [Parameter()]
        [string[]]
        [AllowNull()]
        $WebAppPool,

        [Parameter()]
        [string[]]
        [AllowNull()]
        $WebSiteName,

        [Parameter()]
        [string]
        [AllowNull()]
        $LogPath
        ### End DO NOT REMOVE
    )

    Import-DscResource -ModuleName PowerStig
    Node localhost
    {
        & ([scriptblock]::Create("
            IisSite SiteConfiguration
            {
                $(if ($null -ne $WebAppPool)
                {
                   "WebAppPool = @($( ($WebAppPool | % {"'$_'"}) -join ',' ))`n"
                })
                $( "WebSiteName = @($( ($WebSiteName | % {"'$_'"}) -join ',' ))`n" )
                OsVersion = '$OsVersion'
                StigVersion = '$StigVersion'
                $(if ($null -ne $OrgSettings)
                {
                    "Orgsettings = '$OrgSettings'"
                })
                $(if ($null -ne $Exception)
                {
                    "Exception = @{$( ($Exception | % {"'$_'= @{'Value'='1234567'}"}) -join "`n" )}"
                })
                $(if ($null -ne $SkipRule)
                {
                    "SkipRule = @($( ($SkipRule | % {"'$_'"}) -join ',' ))`n"
                }
                if ($null -ne $SkipRuleType)
                {
                    "SkipRuleType = @($( ($SkipRuleType | % {"'$_'"}) -join ',' ))`n"
                })
            }")
        )
    }
}
