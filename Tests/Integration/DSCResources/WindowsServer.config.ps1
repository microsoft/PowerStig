configuration WindowsServer_config
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
        $ResourceParameters,

        [Parameter()]
        [object]
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
        $psboundParams = $PSBoundParameters
        $psboundParams.OsVersion = $psboundParams['TechnologyVersion']
        $psboundParams.OsRole = $psboundParams['TechnologyRole']
        $psboundParams.Remove('TechnologyRole')
        $psboundParams.Remove('ConfigurationData')
        $psboundParams.Remove('TechnologyVersion')

        $resourceParamString = New-ResourceParameterString -ResourceParameters $ResourceParameters -PSBoundParams $psboundParams
        $resourceScriptBlockString = New-ResourceString -ResourceParameterString $resourceParamString -ResourceName WindowsServer
        & ([scriptblock]::Create($resourceScriptBlockString))
    }
}
