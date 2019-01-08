Configuration OracleJRE_config
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
        OracleJRE OracleConfiguration
        {
            ConfigPath = '$ConfigPath'
            PropertiesPath = '$PropertiesPath'
            StigVersion = '$StigVersion'
            $(if ($null -ne $OrgSettings)
            {
                "Orgsettings = '$OrgSettings'"
            })
            $(if ($null -ne $Exception)
            {
                "Exception = @{$( ($Exception | ForEach-Object {"'$PSItem'= @{'Value'='1234567'}"}) -join "`n" )}"
            })
            $(if ($null -ne $SkipRule)
            {
                "SkipRule = @($( ($SkipRule | ForEach-Object {"'$PSItem'"}) -join ',' ))`n"
            })
        }")
        )
    }
}
