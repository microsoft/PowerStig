Configuration OracleJRE_config
{
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $ConfigPath,

        [Parameter(Mandatory = $true)]
        [string]
        $PropertiesPath,

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
                "Exception = @{'$Exception'= @{'Value'='ExceptionTest'}}"
            })
            $(if ($null -ne $SkipRule)
            {
                "SkipRule = @($( ($SkipRule | % {"'$_'"}) -join ',' ))`n"
            })
        }")
        )
    }
}
