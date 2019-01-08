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
            break
       }
       'FileContentRule'
       {
            $resourceMatchStatement = '$PSItem.ResourceID -match "\[ReplaceText\]"'
            break
       }
       'IisLoggingRule'
       {
            $resourceMatchStatement = '$PSItem.ResourceID -match "\[xIisLogging\]" -or $PSItem.ResourceID -match "\[xWebSite\]"'
            break
       }
       'WebConfigurationPropertyRule'
       {
            $resourceMatchStatement = '$PSItem.ResourceID -match "\[xWebConfigProperty\]"'
            break
       }
       'MimeTypeRule'
       {
            $resourceMatchStatement = '$PSItem.ResourceID -match "\[xIisMimeTypeMapping\]"'
            break
       }
       'PermissionRule'
       {
            $resourceMatchStatement = '$PSItem.ResourceID -match "\[NTFSAccessEntry\]" -or $PSItem.ResourceID -match "\[RegistryAccessEntry\]"'
            break
       }
       'WindowsFeatureRule'
       {
            $resourceMatchStatement = '$PSItem.ResourceID -match "\[WindowsFeature\]" -or $PSItem.ResourceID -match "\[WindowsOptionalFeature\]"'
            break
       }
       'WebAppPoolRule'
       {
            $resourceMatchStatement = '$PSItem.ResourceID -match "\[xWebAppPool\]"'
            break
       }
       'KeyValuePairRule'
       {
            $resourceMatchStatement = '$PSItem.ResourceID -match "\[KeyValuePairFile\]"'
            break
       }
       'SqlScriptQueryRule'
       {
            $resourceMatchStatement = '$PSItem.ResourceID -match "\[SqlScriptQuery\]"'
            break
       }
       'AccountPolicyRule'
       {
            $resourceMatchStatement = '$PSItem.ResourceID -match "\[AccountPolicy\]"'
            break
       }
       'AuditPolicyRule'
       {
            $resourceMatchStatement = '$PSItem.ResourceID -match "\[AuditPolicySubcategory\]"'
            break
       }
       'Group'
       {
            $resourceMatchStatement = '$PSItem.ResourceID -match "\[Group\]"'
            break
       }
       'ProcessMitigationRule'
       {
            $resourceMatchStatement = '$PSItem.ResourceID -match "\[ProcessMitigation\]"'
            break
       }
       'SecurityOptionRule'
       {
            $resourceMatchStatement = '$PSItem.ResourceID -match "\[SecurityOption\]"'
            break
       }
       'ServiceRule'
       {
            $resourceMatchStatement = '$PSItem.ResourceID -match "\[xService\]"'
            break
       }
       'UserRightRule'
       {
            $resourceMatchStatement = '$PSItem.ResourceID -match "\[UserRightsAssignment\]"'
            break
       }
       'WmiRule'
       {
            $resourceMatchStatement = '$PSItem.ResourceID -match "\[Script\]"'
            break
       }
       'WinEventLogRule'
       {
            $resourceMatchStatement = '$PSItem.ResourceID -match "\[xWinEventLog\]"'
            break
       }
       'DnsServerRootHintRule'
       {
            $resourceMatchStatement = '$PSItem.ResourceID -match "\[script\]"'
            break
       }
       'DnsServerSettingRule'
       {
            $resourceMatchStatement = '$PSItem.ResourceID -match "\[xDnsServerSetting\]"'
            break
       }
   }
   return $resourceMatchStatement
}
