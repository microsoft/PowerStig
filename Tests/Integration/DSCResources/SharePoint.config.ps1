configuration SharePoint_config
{
    [CmdletBinding()]
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
        [hashtable]
        $Exception,

        [Parameter()]
        [hashtable]
        $BackwardCompatibilityException,

        [Parameter()]
        [string[]]
        $SkipRule,

        [Parameter()]
        [string[]]
        $SkipRuleType,

        [Parameter()]
        [object]
        $OrgSettings,

        [Parameter()]
        [string]
        $WebAppUrl,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [pscredential]
        $SetupAccount
    )

    Import-DscResource -ModuleName PowerStig

    Node localhost
    {
        $psboundParams = $PSBoundParameters
        $psboundParams.Remove('TechnologyRole')
        $psboundParams.Remove('ConfigurationData')
        $psboundParams.Version = $psboundParams['TechnologyVersion']
        $psboundParams.Remove('TechnologyVersion')
        $resourceParameters = @(
            'Version'
            'StigVersion'
            'Exception'
            'SkipRule'
            'SkipRuleType'
            'OrgSettings'
            'SetupAccount'
            'WebAppUrl'
        )

        $resourceParamString = New-ResourceParameterString -ResourceParameters $resourceParameters -PSBoundParams $psboundParams
        $resourceScriptBlockString = New-ResourceString -ResourceParameterString $resourceParamString -ResourceName Sharepoint
        & ([scriptblock]::Create($resourceScriptBlockString))
    }
}
