configuration WindowsDefender_config
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
        [string]
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
        $OrgSettings
    )

    Import-DscResource -ModuleName PowerStig

    Node localhost
    {
        $psboundParams = $PSBoundParameters
        $psboundParams.Remove('TechnologyRole')
        $psboundParams.Remove('ConfigurationData')
        $psboundParams.Remove('TechnologyVersion')

        $resourceParamString = New-ResourceParameterString -ResourceParameters $ResourceParameters -PSBoundParams $psboundParams
        $resourceScriptBlockString = New-ResourceString -ResourceParameterString $resourceParamString -ResourceName WindowsDefender
        & ([scriptblock]::Create($resourceScriptBlockString))
    }
}

