Configuration IisSite_config
{
    param
    (
        [Parameter()]
        [string[]]
        $WebAppPool,

        [Parameter(Mandatory = $true)]
        [string[]]
        $WebSiteName,

        [Parameter(Mandatory = $true)]
        [string]
        $OsVersion,

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
        $OrgSettings
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
                    "Exception = @{'$Exception'= @{'Value'='1234567'}}"
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
