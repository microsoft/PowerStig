Configuration WindowsFirewall_config
{
    param
    (
        [Parameter(Mandatory = $true)]
        [version]
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
        WindowsFirewall BaseLineSettings
        {
            StigVersion = '$StigVersion'
            $(if ($null -ne $Exception)
            {
                "Exception = @{'$Exception'= @{'ValueData'='1234567'}}"
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

