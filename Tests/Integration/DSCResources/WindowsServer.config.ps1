Configuration WindowsServer_config
{
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $OVersion,

        [Parameter(Mandatory = $true)]
        [string]
        $OsRole,

        [Parameter(Mandatory = $true)]
        [version]
        $StigVersion,

        [Parameter(Mandatory = $true)]
        [string]
        $ForestName,

        [Parameter(Mandatory = $true)]
        [string]
        $DomainName,

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
            WindowsServer BaseLineSettings
            {
                OsVersion    = '$OsVersion'
                OsRole       = '$osRole'
                StigVersion  = '$StigVersion'
                ForestName   = '$ForestName'
                DomainName   = '$DomainName'
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

        <#
            This is a little hacky becasue the scriptblock "flattens" the array of rules to skip.
            This just rebuilds the array text in the scriptblock.
        #>
    }
}
