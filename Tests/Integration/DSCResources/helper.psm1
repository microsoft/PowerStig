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
    }
}
#endregion

<#
    .SYNOPSIS
        Returns a regex  pattern used to find the dsc resource names in a mof.
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
            return '\[Registry\]|\[cAdministrativeTemplateSetting\]'
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
        [Parameter(Mandatory=$true,ValueFromPipeLine=$true)]
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
        $Count
    )

    $randomExceptionRuleId = Get-Random -InputObject $PowerStigXml.($RuleType).Rule.id -Count $Count
    $stigException = @{}
    foreach ($id in $randomExceptionRuleId)
    {
        $exceptionRuleHashtable = @{
            $exceptionRuleParameterValues[$RuleType] = $ParameterValue
        }
        $stigException.Add($id, $exceptionRuleHashtable)
    }
    return $stigException
}
