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
       'SqlScriptQuery'
       {
            $resourceMatchStatement = '$PSItem.ResourceID -match "\[SqlScriptQuery\]"'
            break
       }
       'AccountPolicy'
       {
            $resourceMatchStatement = '$PSItem.ResourceID -match "\[AccountPolicy\]"'
            break
       }
       'AuditPolicy'
       {
            $resourceMatchStatement = '$PSItem.ResourceID -match "\[AuditPolicySubcategory\]"'
            break
       }
       'Group'
       {
            $resourceMatchStatement = '$PSItem.ResourceID -match "\[Group\]"'
            break
       }
       'ProcessMitigation'
       {
            $resourceMatchStatement = '$PSItem.ResourceID -match "\[ProcessMitigation\]"'
            break
       }
       'SecurityOption'
       {
            $resourceMatchStatement = '$PSItem.ResourceID -match "\[SecurityOption\]"'
            break
       }
       'Service'
       {
            $resourceMatchStatement = '$PSItem.ResourceID -match "\[xService\]"'
            break
       }
       'UserRightsAssignment'
       {
            $resourceMatchStatement = '$PSItem.ResourceID -match "\[UserRightsAssignment\]"'
            break
       }
       'WMI'
       {
            $resourceMatchStatement = '$PSItem.ResourceID -match "\[Script\]"'
            break
       }
       'xWinEventLog'
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
