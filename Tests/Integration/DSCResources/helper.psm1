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
            return '\[xRegistry\]|\[cAdministrativeTemplateSetting\]'
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
            return '\[xWindowsFeature\]|\[xWindowsOptionalFeature\]'
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
            return '\[xService\]'
        }
        'UserRightRule'
        {
            return '\[UserRightsAssignment\]'
        }
        'WmiRule'
        {
            return '\[Script\]'
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
