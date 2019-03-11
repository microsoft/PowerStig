Configuration Office_config
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
        Office BaseLineSettings
        {
            OfficeApp   = '$TechnologyVersion'
            StigVersion = '$StigVersion'
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
            })
        }")
        )
    }
}
