Configuration IisSite_config
{
    param
    (
        [Parameter()]
        [AllowNull()]
        [string]
        $TechnologyVersion,

        [Parameter()]
        [AllowNull()]
        [string]
        $TechnologyRole,

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

        [Parameter()]
        [AllowNull()]
        [string[]]
        $WebAppPool,

        [Parameter()]
        [AllowNull()]
        [string[]]
        $WebSiteName
    )

    Import-DscResource -ModuleName PowerStig
    Node localhost
    {
        & ([scriptblock]::Create("
            IisSite SiteConfiguration
            {
                IisVersion  = '$TechnologyVersion'
                StigVersion = '$StigVersion'
                $(if ($null -ne $WebAppPool)
                {
                   "WebAppPool = @($( ($WebAppPool | ForEach-Object {"'$PSItem'"}) -join ',' ))`n"
                })
                $( "WebSiteName = @($( ($WebSiteName | ForEach-Object {"'$PSItem'"}) -join ',' ))`n" )
                $(if ($null -ne $OrgSettings)
                {
                    "Orgsettings = '$OrgSettings'"
                })
                $(if ($null -ne $Exception)
                {
                    "Exception = @{$( ($Exception | ForEach-Object {"'$PSItem' = '1234567'"}) -join "`n" )}"
                })
                $(if ($null -ne $SkipRule)
                {
                    "SkipRule = @($( ($SkipRule | ForEach-Object {"'$PSItem'"}) -join ',' ))`n"
                }
                if ($null -ne $SkipRuleType)
                {
                    "SkipRuleType = @($( ($SkipRuleType | ForEach-Object {"'$PSItem'"}) -join ',' ))`n"
                })
            }")
        )
    }
}
