#region Data
data exceptionRuleParameterValues
{
    @{
        PermissionRule               = 'AccessControlEntry'
        SqlScriptQueryRule           = 'SetScript'
        AuditPolicyRule              = 'Ensure'
        DnsServerSettingRule         = 'PropertyValue'
        WebConfigurationPropertyRule = 'Value'
        RegistryRule                 = 'ValueData'
        FileContentRule              = 'Value'
        AccountPolicyRule            = 'PolicyValue'
        IISLoggingRule               = 'LogCustomFieldEntry'
        DnsServerRootHintRule        = 'IpAddress'
        SslSettingsRule              = 'Value'
        GroupRule                    = 'MembersToExclude'
        WebAppPoolRule               = 'Value'
        WinEventLogRule              = 'IsEnabled'
        SecurityOptionRule           = 'OptionValue'
        ProcessMitigationRule        = 'Disable'
        MimeTypeRule                 = 'Ensure'
        WindowsFeatureRule           = 'Ensure'
        AuditSettingRule             = 'Operator'
        ServiceRule                  = 'StartupType'
        UserRightRule                = 'Identity'
        VsphereAdvancedSettingsRule  = 'AdvancedSettings'
        SPWebAppGeneralSettingsRule  = 'PropertyValue' # using example from DnsServerSettingRule
    }
}
#endregion

<#
    .SYNOPSIS
        Returns a regex pattern used to find the dsc resource names in a mof.
#>
function Get-ResourceMatchStatement
{
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $RuleName
    )

    switch ($RuleName)
    {
        'RegistryRule'
        {
            return '\[Registry\]|\[RegistryPolicyFile\]'
        }
        'FileContentRule'
        {
            return '\[ReplaceText\]|\[KeyValuePairFile\]'
        }
        'IisLoggingRule'
        {
            return '\[xIisLogging\]|\[xWebSite\]'
        }
        'WebConfigurationPropertyRule'
        {
            return '\[xWebConfigProperty\]'
        }
        'MimeTypeRule'
        {
            return '\[xIisMimeTypeMapping\]'
        }
        'PermissionRule'
        {
            return '\[NTFSAccessEntry\]|\[RegistryAccessEntry\]'
        }
        'WindowsFeatureRule'
        {
            return '\[WindowsFeature\]|\[WindowsOptionalFeature\]'
        }
        'WebAppPoolRule'
        {
            return '\[xWebAppPool\]'
        }
        'KeyValuePairRule'
        {
            return '\[KeyValuePairFile\]'
        }
        'SqlScriptQueryRule'
        {
            return '\[SqlScriptQuery\]'
        }
        'AccountPolicyRule'
        {
            return '\[AccountPolicy\]'
        }
        'AuditPolicyRule'
        {
            return '\[AuditPolicySubcategory\]'
        }
        'Group'
        {
            return '\[Group\]'
        }
        'ProcessMitigationRule'
        {
            return '\[ProcessMitigation\]'
        }
        'SecurityOptionRule'
        {
            return '\[SecurityOption\]'
        }
        'ServiceRule'
        {
            return '\[Service\]'
        }
        'UserRightRule'
        {
            return '\[UserRightsAssignment\]'
        }
        'AuditSettingRule'
        {
            return '\[AuditSetting\]'
        }
        'WinEventLogRule'
        {
            return '\[WindowsEventLog\]'
        }
        'DnsServerRootHintRule'
        {
            return '\[script\]'
        }
        'DnsServerSettingRule'
        {
            return '\[xDnsServerSetting\]'
        }
        'SslSettingsRule'
        {
            return '\[xSSLSettings\]'
        }
        'VsphereAcceptanceLevelRule'
        {
            return '\[VMHostAcceptanceLevel\]'
        }
        'VsphereAdvancedSettingsRule'
        {
            return '\[VMHostAdvancedSettings\]'
        }
        'VsphereKernelActiveDumpPartitionRule'
        {
            return '\[VMHostVMKernelActiveDumpPartition\]'
        }
        'VsphereNtpSettingsRule'
        {
            return '\[VMHostNtpSettings\]'
        }
        'VspherePortGroupSecurityRule'
        {
            return '\[VMHostVssPortGroupSecurity\]'
        }
        'VsphereServiceRule'
        {
            return '\[VMHostService\]'
        }
        'VsphereSnmpAgentRule'
        {
            return '\[VMHostSnmpAgent\]'
        }
        'VsphereVssSecurityRule'
        {
            return '\[VMHostVssSecurity\]'
        }
        'SharePointSPWebAppGeneralSettingsRule' 
        {
            return '\[SharePointSPWebAppGeneralSettingsRule\]'
        }
    }
}

<#
    .SYNOPSIS
        Removes the rules that have dscresource equal to 'None'.
        The integration tests randomly picks rules and if the rule has a dscresource='None' the test will fail
        causing an intermitent build failure.

    .PARAMETER Xml
        The xml that will be examined.
#>
function Remove-DscResourceEqualsNone
{
    [CmdletBinding()]
    [OutputType([xml])]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeLine = $true)]
        [xml]
        $Xml
    )

    $stigRuleNames = $Xml.DISASTIG | Get-Member -Type Property |
        Where-Object -FilterScript {$PSItem.Name -match 'Rule$' -and $PSItem.Name -notmatch 'DocumentRule|ManualRule'}

    # remove all dscresource -eq None
    foreach ($stigRuleName in $stigRuleNames.Name)
    {
        foreach ($node in $Xml.DISASTIG.$stigRuleName.Rule)
        {
            if ($node.dscresource -eq 'None')
            {
                [void]$xml.DISASTIG.$stigRuleName.RemoveChild($node)
            }

        }
    }

    return $Xml.DISASTIG
}

function Remove-SkipRuleBlankOrgSetting
{
    [CmdletBinding()]
    [OutputType([xml])]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeLine = $true)]
        [System.Xml.XmlElement]
        $Xml,

        [Parameter(Mandatory = $true)]
        [ValidateScript({Test-Path -Path $_})]
        [string]
        $OrgSettingPath
    )

    $blankOrgSettingRuleIds = Get-BlankOrgSettingRuleId -OrgSettingPath $OrgSettingPath
    $stigRuleNames = $Xml | Get-Member -Type Property |
        Where-Object -FilterScript {$PSItem.Name -match 'Rule$' -and $PSItem.Name -notmatch 'DocumentRule|ManualRule'}

    foreach ($stigRuleName in $stigRuleNames.Name)
    {
        foreach ($node in $Xml.$stigRuleName.Rule)
        {
            if ($blankOrgSettingRuleIds -contains $node.id)
            {
                [void]$xml.$stigRuleName.RemoveChild($node)
            }
        }
    }

    return $Xml
}

function Get-BlankOrgSettingRuleId
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateScript({Test-Path -Path $_})]
        [string]
        $OrgSettingPath
    )

    # Import the xml and determine if there are any blank org setting values
    [xml] $orgSettingsXml = Get-Content -Path $OrgSettingPath
    $orgSettingAttributes = $orgSettingsXml.OrganizationalSettings.OrganizationalSetting
    $trackEmptyOrgSetting = @()
    foreach ($orgSettingAttribute in $orgSettingAttributes)
    {
        for ($i = 0; $i -lt ($orgSettingAttribute.Attributes.Name).Count; $i++)
        {
            $attributeName = $orgSettingAttribute.Attributes.Name[$i]
            if ([string]::IsNullOrEmpty($orgSettingAttribute.$attributeName))
            {
                $trackEmptyOrgSetting += $orgSettingAttribute.id
            }
        }
    }

    return $trackEmptyOrgSetting | Select-Object -Unique
}

function Get-RandomExceptionRule
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $RuleType,

        [Parameter(Mandatory = $true)]
        [object]
        $PowerStigXml,

        [Parameter(Mandatory = $true)]
        [object]
        $ParameterValue,

        [Parameter(Mandatory = $true)]
        [int]
        $Count,

        [Parameter(Mandatory = $false)]
        [switch]
        $BackwardCompatibility
    )

    $randomExceptionRuleId = Get-Random -InputObject $PowerStigXml.($RuleType).Rule.id -Count $Count
    $stigException = @{}
    foreach ($id in $randomExceptionRuleId)
    {
        $exceptionRuleHashtable = @{
            $exceptionRuleParameterValues[$RuleType] = $ParameterValue
        }
        if ($PSBoundParameters.ContainsKey('BackwardCompatibility'))
        {
            $exceptionRuleHashtable = $ParameterValue
        }
        $stigException.Add($id, $exceptionRuleHashtable)
    }
    return $stigException
}

<#
    .SYNOPSIS
        Creates a string representation of the DSC Configuration parameters

    .DESCRIPTION
        This function is used to help create parameter strings, specifically when non-string
        parameter values are passed to a configuation. If a string parameter value is
        passed to this function, it's contents is expanded as a string, however, if a
        non-string parameter value is passed, the function will pass the variable name
        as a string so that when a scriptblock is created, the contents of that variable
        is then expanded at run time.

    .PARAMETER ResourceParameters
        An array of Resource Parameters that will be used in the string output

    .PARAMETER PSBoundParams
        A hashtable representing the PSBoundParameters that is passed to the DSC Configuration

    .EXAMPLE
        This example is used to create a string representation of the configuration block for the
        Vsphere PowerSTIG DSC Resource.

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

    .NOTES
        This function is derived from "PSDesiredStateConfiguration\BuildResourceCommonParameters"
#>
function New-ResourceParameterString
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Array]
        $ResourceParameters,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Collections.Hashtable]
        $PSBoundParams
    )

    $resourceParameterString = New-Object -TypeName System.Text.StringBuilder

    foreach ($parameterName in $($PSBoundParams.keys))
    {
        if ($parameterName -in $ResourceParameters)
        {
            $value = $PSBoundParams[$parameterName]
            if ($null -eq $value)
            {
                continue
            }

            if ($value -is [System.String])
            {
                [void] $resourceParameterString.AppendFormat('{0} = "{1}"', $parameterName, $value)
                [void] $resourceParameterString.AppendLine()
            }
            else
            {
                [void] $resourceParameterString.Append($parameterName + ' = $' + $parameterName)
                [void] $resourceParameterString.AppendLine()
            }
        }
    }

    return $resourceParameterString.ToString()
}

<#
    .SYNOPSIS
        This function creates a string that represents a DSC Resource with the given
        parameters passed to it.

    .DESCRIPTION
        This function creates a string that represents a DSC Resource with the given
        parameters passed to it (from New-ResourceParameterString).

    .PARAMETER ResourceParameterString
        A string from which is generated via New-ResourceParameterString with the parameters
        that is passed to it.

    .PARAMETER ResourceName
        The resource name for the configuration being used.

    .EXAMPLE
        This example is used to create a string representation of the configuration block for the
        Vsphere PowerSTIG DSC Resource.

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

    .NOTES
        This function is derived from "PSDesiredStateConfiguration\BuildResourceString"
#>
function New-ResourceString
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $ResourceParameterString,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $ResourceName
    )

    $resourceString = New-Object -TypeName System.Text.StringBuilder

    [void] $resourceString.AppendFormat('{0} Baseline', $ResourceName)
    [void] $resourceString.AppendLine()
    [void] $resourceString.AppendLine('{')
    [void] $resourceString.AppendLine()
    [void] $resourceString.AppendLine($ResourceParameterString)
    [void] $resourceString.AppendLine('}')

    return $resourceString.ToString()
}
