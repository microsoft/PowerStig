configuration SqlServer_config
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

        [Parameter()]
        [string]
        $StigVersion,

        [Parameter()]
        [string[]]
        $SkipRule,

        [Parameter()]
        [string[]]
        $SkipRuleType,

        [Parameter()]
        [string[]]
        $SkipRuleSeverity,

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
        [PSCredential]
        $SQLPermCredential

    )

    Import-DscResource -ModuleName PowerStig

    Node localhost
    {
        $sqlPermUser = 'PlaceHolderUser'
        $sqlPermPass = ConvertTo-SecureString "PlaceholderPassword" -AsPlainText -Force
        $sqlPermCredential = New-Object System.Management.Automation.PSCredential ($sqlPermUser, $sqlPermPass)
        
        $psboundParams = $PSBoundParameters
        $psboundParams.SqlVersion = $psboundParams['TechnologyVersion']
        $psboundParams.SqlRole = $psboundParams['TechnologyRole']
        $psboundParams.ServerInstance = 'TestServer'
        $psboundParams.SqlPermCredential = $sqlPermCredential
        $psboundParams.Remove('TechnologyRole')
        $psboundParams.Remove('ConfigurationData')
        $psboundParams.Remove('TechnologyVersion')

        $resourceParamString = New-ResourceParameterString -ResourceParameters $ResourceParameters -PSBoundParams $psboundParams
        $resourceScriptBlockString = New-ResourceString -ResourceParameterString $resourceParamString -ResourceName SqlServer
        & ([scriptblock]::Create($resourceScriptBlockString))
    }
}

configuration SqlServerDatabase_config
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

        [Parameter()]
        [string]
        $StigVersion,

        [Parameter()]
        [psobject]
        $SkipRule,

        [Parameter()]
        [psobject]
        $SkipRuleType,

        [Parameter()]
        [hashtable]
        $Exception,

        [Parameter()]
        [string[]]
        $OrgSettings
    )

    Import-DscResource -ModuleName PowerStig

    Node localhost
    {
        $psboundParams = $PSBoundParameters
        $psboundParams.SqlVersion = $psboundParams['TechnologyVersion']
        $psboundParams.SqlRole = $psboundParams['TechnologyRole']
        $psboundParams.ServerInstance = 'TestServer'
        $psboundParams.Database = @('TestDataBase','TestDataBase2')
        $psboundParams.Remove('TechnologyRole')
        $psboundParams.Remove('ConfigurationData')
        $psboundParams.Remove('TechnologyVersion')

        $resourceParamString = New-ResourceParameterString -ResourceParameters $ResourceParameters -PSBoundParams $psboundParams
        $resourceScriptBlockString = New-ResourceString -ResourceParameterString $resourceParamString -ResourceName SqlServer
        & ([scriptblock]::Create($resourceScriptBlockString))
    }
}
