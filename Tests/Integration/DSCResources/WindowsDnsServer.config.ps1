Configuration WindowsDnsServer_config
{
    param
    (
        [Parameter()]
        [AllowNull()]
        [string]
        $TechnologyVersion,

        [Parameter()]
        [AllowNull()]
        [string]
        $TechnologyRole,

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
        [hashtable]
        $Exception,

        [Parameter()]
        [string[]]
        $OrgSettings,

        [Parameter()]
        [AllowNull()]
        [string]
        $ForestName,

        [Parameter()]
        [AllowNull()]
        [string]
        $DomainName
    )

    Import-DscResource -ModuleName PowerStig

    Node localhost
    {
        & ([scriptblock]::Create("
        WindowsDnsServer BaseLineSettings
        {
            OsVersion   = '$TechnologyVersion'
            StigVersion = '$StigVersion'
            ForestName  = '$ForestName'
            DomainName  = '$DomainName'
            $(if ($null -ne $OrgSettings)
            {
                "Orgsettings = '$OrgSettings'"
            })
            $(if ($null -ne $Exception)
            {
                "Exception = @{`n$($Exception.Keys |
                    ForEach-Object {"'{0}' = {1}{2} = '{3}'{4}`n" -f
                        $PSItem, '@{', $($Exception[$PSItem].Keys), $($Exception[$PSItem][$Exception[$PSItem].Keys]), '}'})}"
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
