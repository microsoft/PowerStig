Configuration WindowsDnsServer_config
{
    param
    (
        [Parameter(Mandatory = $true)]
        [version]
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
        [string]
        $BrowserVersion,

        [Parameter()]
        [AllowNull()]
        [string[]]
        $OfficeApp,

        [Parameter()]
        [AllowNull()]
        [string]
        $ConfigPath,

        [Parameter()]
        [AllowNull()]
        [string]
        $PropertiesPath,

        [Parameter()]
        [AllowNull()]
        [string]
        $SqlVersion,

        [Parameter()]
        [AllowNull()]
        [string]
        $SqlRole,

        [Parameter()]
        [AllowNull()]
        [string]
        $ForestName,

        [Parameter()]
        [AllowNull()]
        [string]
        $DomainName,

        [Parameter()]
        [AllowNull()]
        [string]
        $OsVersion,

        [Parameter()]
        [AllowNull()]
        [string]
        $OsRole,

        [Parameter()]
        [AllowNull()]
        [string[]]
        $WebAppPool,

        [Parameter()]
        [AllowNull()]
        [string[]]
        $WebSiteName,

        [Parameter()]
        [AllowNull()]
        [string]
        $LogPath
    )

    Import-DscResource -ModuleName PowerStig

    Node localhost
    {
        & ([scriptblock]::Create("
        WindowsDnsServer BaseLineSettings
        {
            OsVersion = '$OsVersion'
            StigVersion = '$StigVersion'
            ForestName = '$ForestName'
            DomainName = '$DomainName'
            $(if ($null -ne $OrgSettings)
            {
                "Orgsettings = '$OrgSettings'"
            })
            $(if ($null -ne $Exception)
            {
                "Exception = @{$( ($Exception | ForEach-Object {"'$PSItem'= @{'PropertyValue'='1234567'}"}) -join "`n" )}"
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
