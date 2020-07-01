configuration Vsphere_config
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
        [version]
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

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $HostIP,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $ServerIP,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        $Credential,

        [Parameter()]
        [string[]]
        $VirtualStandardSwitchGroup,

        [Parameter()]
        [string[]]
        $VmGroup
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
            'HostIP'
            'ServerIP'
            'Credential'
            'VirtualStandardSwitchGroup'
            'VmGroup'
        )

        $resourceParamString = New-ResourceParameterString -ResourceParameters $resourceParameters -PSBoundParams $psboundParams
        $resourceScriptBlockString = New-ResourceString -ResourceParameterString $resourceParamString -ResourceName Vsphere
        & ([scriptblock]::Create($resourceScriptBlockString))
    }
}
