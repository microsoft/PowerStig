using module .\..\Rule.AccountPolicy\AccountPolicyRule.psm1
using module .\..\Rule.AuditPolicy\AuditPolicyRule.psm1
using module .\..\Rule.DnsServerRootHint\DnsServerRootHintRule.psm1
using module .\..\Rule.DnsServerSetting\DnsServerSettingRule.psm1
using module .\..\Rule.Document\DocumentRule.psm1
using module .\..\Rule.FileContent\FileContentRule.psm1
using module .\..\Rule.Group\GroupRule.psm1
using module .\..\Rule.IISLogging\IISLoggingRule.psm1
using module .\..\Rule.Manual\ManualRule.psm1
using module .\..\Rule.MimeType\MimeTypeRule.psm1
using module .\..\Rule.Permission\PermissionRule.psm1
using module .\..\Rule.ProcessMitigation\ProcessMitigationRule.psm1
using module .\..\Rule.Registry\RegistryRule.psm1
using module .\..\Rule.SecurityOption\SecurityOptionRule.psm1
using module .\..\Rule.Service\ServiceRule.psm1
using module .\..\Rule.SqlScriptQuery\SqlScriptQueryRule.psm1
using module .\..\Rule.UserRightsAssignment\UserRightsAssignmentRule.psm1
using module .\..\Rule.WebAppPool\WebAppPoolRule.psm1
using module .\..\Rule.WebConfigurationProperty\WebConfigurationPropertyRule.psm1
using module .\..\Rule.WindowsFeature\WindowsFeatureRule.psm1
using module .\..\Rule.WinEventLog\WinEventLogRule.psm1
using module .\..\Rule.Wmi\WmiRule.psm1
#header

class LoadFactory
{
    static [psobject] Rule ([xml.xmlelement] $Rule)
    {
        $return = $null
        switch($Rule.ParentNode.Name)
        {
            'AccountPolicyRule'             {$return = [AccountPolicyRule]::new($Rule)}
            'AuditPolicyRule'               {$return = [AuditPolicyRule]::new($Rule)}
            'DnsServerSettingRule'          {$return = [DnsServerSettingRule]::new($Rule)}
            'DnsServerRootHintRule'         {$return = [DnsServerRootHintRule]::new($Rule)}
            'DocumentRule'                  {$return = [DocumentRule]::new($Rule)}
            'FileContentRule'               {$return = [FileContentRule]::new($Rule)}
            'GroupRule'                     {$return = [GroupRule]::new($Rule)}
            'IisLoggingRule'                {$return = [IisLoggingRule]::new($Rule)}
            'MimeTypeRule'                  {$return = [MimeTypeRule]::new($Rule)}
            'ManualRule'                    {$return = [ManualRule]::new($Rule)}
            'PermissionRule'                {$return = [PermissionRule]::new($Rule)}
            'ProcessMitigationRule'         {$return = [ProcessMitigationRule]::new($Rule)}
            'RegistryRule'                  {$return = [RegistryRule]::new($Rule)}
            'SecurityOptionRule'            {$return = [SecurityOptionRule]::new($Rule)}
            'ServiceRule'                   {$return = [ServiceRule]::new($Rule)}
            'SqlScriptQueryRule'            {$return = [SqlScriptQueryRule]::new($Rule)}
            'UserRightRule'                 {$return = [UserRightRule]::new($Rule)}
            'WebAppPoolRule'                {$return = [WebAppPoolRule]::new($Rule)}
            'WebConfigurationPropertyRule'  {$return = [WebConfigurationPropertyRule]::new($Rule)}
            'WindowsFeatureRule'            {$return = [WindowsFeatureRule]::new($Rule)}
            'WinEventLogRule'               {$return = [WinEventLogRule]::new($Rule)}
            'WmiRule'                       {$return = [WmiRule]::new($Rule)}
        }

        return $return
    }
}
