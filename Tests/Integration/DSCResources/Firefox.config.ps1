Configuration Firefox_config
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
        $Exception
    )

    Import-DscResource -ModuleName PowerStig

    Node localhost
    {
        & ([scriptblock]::Create("
        Firefox FirefoxConfiguration
        {
            Stigversion = '$StigVersion'
            $(if ($null -ne $Exception)
            {
                "Exception = @{'$Exception'= @{'Value'='1234567'}}"
            })
            $(if ($null -ne $SkipRule)
            {
                "SkipRule = @($( ($SkipRule | % {"'$_'"}) -join ',' ))`n"
            })
        }")
        )
    }
}
