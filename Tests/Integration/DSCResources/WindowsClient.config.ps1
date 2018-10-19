Configuration WindowsClient_config
{
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $OsVersion,

        [Parameter(Mandatory = $true)]
        [version]
        $StigVersion,

        [Parameter(Mandatory = $true)]
        [string]
        $ForestName,

        [Parameter()]
        [string]
        $Exception,

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
            WindowsClient BaseLineSettings
            {
                OsVersion    = '$OsVersion'
                StigVersion  = '$stigVersion'
                ForestName   = '$forestName'
                DomainName   = '$domainName'
                $(if ($null -ne $skipRule)
                {
                    "SkipRule = @($( ($skipRule | % {"'$_'"}) -join ',' ))`n"
                }
                if ($null -ne $skipRuleType)
                {
                    " SkipRuleType = @($( ($skipRuleType | % {"'$_'"}) -join ',' ))`n"
                })
            }")
        )

        <#
            This is a little hacky becasue the scriptblock "flattens" the array of rules to skip.
            This just rebuilds the array text in the scriptblock.
        #>
    }
}
