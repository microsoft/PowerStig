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
                $resourceMatchStatement = '$PSItem.ResourceID -match "\[xRegistry\]" -or $PSItem.ResourceID -match "\[cAdministrativeTemplateSetting\]"'
        }
        'FileContentRule'
        {
                $resourceMatchStatement = '$PSItem.ResourceID -match "\[ReplaceText\]"'
        }
        'IisLoggingRule'
        {
                $resourceMatchStatement = '$PSItem.ResourceID -match "\[xIisLogging\]" -or $PSItem.ResourceID -match "\[xWebSite\]"'
        }
        'WebConfigurationPropertyRule'
        {
                $resourceMatchStatement = '$PSItem.ResourceID -match "\[xWebConfigProperty\]"'
        }
        'MimeTypeRule'
        {
                $resourceMatchStatement = '$PSItem.ResourceID -match "\[xIisMimeTypeMapping\]"'
        }
        'PermissionRule'
        {
                $resourceMatchStatement = '$PSItem.ResourceID -match "\[NTFSAccessEntry\]" -or $PSItem.ResourceID -match "\[RegistryAccessEntry\]"'
        }
        'WindowsFeatureRule'
        {
                $resourceMatchStatement = '$PSItem.ResourceID -match "\[WindowsFeature\]" -or $PSItem.ResourceID -match "\[WindowsOptionalFeature\]"'
        }
        'WebAppPoolRule'
        {
                $resourceMatchStatement = '$PSItem.ResourceID -match "\[xWebAppPool\]"'
        }
        'KeyValuePairRule'
        {
                $resourceMatchStatement = '$PSItem.ResourceID -match "\[KeyValuePairFile\]"'
        }
        'SqlScriptQueryRule'
        {
                $resourceMatchStatement = '$PSItem.ResourceID -match "\[SqlScriptQuery\]"'
        }
        'AccountPolicyRule'
        {
                $resourceMatchStatement = '$PSItem.ResourceID -match "\[AccountPolicy\]"'
        }
        'AuditPolicyRule'
        {
                $resourceMatchStatement = '$PSItem.ResourceID -match "\[AuditPolicySubcategory\]"'
        }
        'Group'
        {
                $resourceMatchStatement = '$PSItem.ResourceID -match "\[Group\]"'
        }
        'ProcessMitigationRule'
        {
                $resourceMatchStatement = '$PSItem.ResourceID -match "\[ProcessMitigation\]"'
        }
        'SecurityOptionRule'
        {
                $resourceMatchStatement = '$PSItem.ResourceID -match "\[SecurityOption\]"'
        }
        'ServiceRule'
        {
                $resourceMatchStatement = '$PSItem.ResourceID -match "\[xService\]"'
        }
        'UserRightRule'
        {
                $resourceMatchStatement = '$PSItem.ResourceID -match "\[UserRightsAssignment\]"'
        }
        'WmiRule'
        {
                $resourceMatchStatement = '$PSItem.ResourceID -match "\[Script\]"'
        }
        'WinEventLogRule'
        {
                $resourceMatchStatement = '$PSItem.ResourceID -match "\[xWinEventLog\]"'
        }
        'DnsServerRootHintRule'
        {
                $resourceMatchStatement = '$PSItem.ResourceID -match "\[script\]"'
        }
        'DnsServerSettingRule'
        {
                $resourceMatchStatement = '$PSItem.ResourceID -match "\[xDnsServerSetting\]"'
        }
        'SslSettingRule'
        {
                $resourceMatchStatement = '$PSItem.ResourceID -match "\[xSslSettings\]"'
        }
    }

    return $resourceMatchStatement
}
