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
        $SkipRuleType
    )

    Import-DscResource -ModuleName PowerStig

    Node localhost
    {
        & ([scriptblock]::Create("
        WindowsFirewall BaseLineSettings
        {
            StigVersion  = '$StigVersion'
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
