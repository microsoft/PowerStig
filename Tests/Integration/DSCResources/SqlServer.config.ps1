Configuration SqlServer_config
{
    param
    (
        [Parameter()]
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

    )

    Import-DscResource -ModuleName PowerStig

    Node localhost
    {
        & ([scriptblock]::Create("
        SqlServer Instance
        {
            SqlVersion = $SqlVersion
            SqlRole = '$SqlRole'
            StigVersion = $StigVersion
            ServerInstance = 'TestServer'
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
                " SkipRuleType = @($( ($SkipRuleType | ForEach-Object {"'$PSItem'"}) -join ',' ))`n"
            })
        }")
        )
    }
}

Configuration SqlServerDatabase_config
{
    param
    (
        [Parameter()]
        [string]
        $StigVersion,

        [Parameter()]
        [psobject]
        $SkipRule,

        [Parameter()]
        [psobject]
        $SkipRuleType,

        [Parameter()]
        [psobject]
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
        SqlServer Database
        {
            SqlVersion = '$SqlVersion'
            SqlRole = '$SqlRole'
            StigVersion = '$StigVersion'
            ServerInstance = 'TestServer'
            Database = 'TestDataBase'
            $(if ($null -ne $OrgSettings)
            {
                "Orgsettings = '$OrgSettings'"
            })
            $(if ($null -ne $Exception)
            {
                "Exception = @{$( ($Exception | ForEach-Object {"'$PSItem'= @{'SetScript'='TestScript'}"}) -join "`n" )}"
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
