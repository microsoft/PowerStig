Configuration SqlServerInstance_config
{
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $SqlVersion,

        [Parameter(Mandatory = $true)]
        [string]
        $SqlRole,

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
        $Exception
        
    )

    Import-DscResource -ModuleName PowerStig

    Node localhost
    {
        & ([scriptblock]::Create("
        SqlServer Instance
        {
            SqlVersion     = '$SqlVersion'
            SqlRole        = '$SqlRole'
            StigVersion  = '$StigVersion'
            ServerInstance = 'TestServer'
            $(if ($null -ne $Exception)
            {
                "Exception    = @{'$Exception'= @{'SetScript'='TestScript'}}"
            })
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

Configuration SqlServerDatabase_config
{
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $SqlVersion,

        [Parameter(Mandatory = $true)]
        [string]
        $SqlRole,

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
        $Exception
    )

    Import-DscResource -ModuleName PowerStig

    Node localhost
    {
        & ([scriptblock]::Create("
        SqlServer Database
        {
            SqlVersion     = '$SqlVersion'
            SqlRole        = '$SqlRole'
            StigVersion  = '$StigVersion'
            ServerInstance = 'TestServer'
            Database       = 'TestDataBase'
            $(if ($null -ne $Exception)
            {
                "Exception    = @{'$Exception'= @{'SetScript'='TestScript'}}"
            })
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
