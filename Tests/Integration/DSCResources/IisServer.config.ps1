Configuration IisServer_Config
{
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $OsVersion,

        [Parameter(Mandatory = $true)]
        [string]
        $StigVersion,

        [Parameter(Mandatory = $true)]
        [string]
        $LogPath,

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
            IisServer ServerConfiguration
            {
                OsVersion   = '$OsVersion'
                StigVersion = '$StigVersion'
                LogPath     = '$LogPath'
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
