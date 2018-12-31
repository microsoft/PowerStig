Configuration WindowsClient_config
{
    param
    (

        [Parameter(Mandatory = $true)]
        [version]
        $StigVersion,

        [Parameter()]
        [string[]]
        $Exception,

        [Parameter()]
        [string[]]
        $SkipRule,

        [Parameter()]
        [string[]]
        $SkipRuleType,

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
            WindowsClient BaseLineSettings
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
                    "Exception = @{$( ($Exception | % {"'$_'= @{'ValueData'='1234567'}"}) -join "`n" )}"
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

        <#
            This is a little hacky becasue the scriptblock "flattens" the array of rules to skip.
            This just rebuilds the array text in the scriptblock.
        #>
    }
}
