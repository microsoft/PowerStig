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
        [psobject]
        $SkipRule,

        [Parameter()]
        [psobject]
        $SkipRuleType
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
                $(if ($null -ne $SkipRule)
                {
                    "SkipRule = @($( ($SkipRule | % {"'$_'"}) -join ',' ))`n"
                }
                if ($null -ne $SkipRuleType)
                {
                    " SkipRuleType = @($( ($SkipRuleType | % {"'$_'"}) -join ',' ))`n"
                })
            }")
        )
    }
}
