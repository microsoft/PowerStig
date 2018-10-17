Configuration WindowsClient_config
{
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $osVersion,

        [Parameter(Mandatory = $true)]
        [version]
        $stigVersion,

        [Parameter(Mandatory = $true)]
        [string]
        $forestName,

        [Parameter()]
        [string]
        $exception,

        [Parameter(Mandatory = $true)]
        [string]
        $domainName,

        [Parameter()]
        [psobject]
        $skipRule,

        [Parameter()]
        [psobject]
        $skipRuleType
    )

    Import-DscResource -ModuleName PowerStig

    Node localhost
    {
        & ([scriptblock]::Create("
            WindowsClient BaseLineSettings
            {
                OsVersion    = '$osVersion'
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
