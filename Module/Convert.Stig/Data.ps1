# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

data DscResource
{
    ConvertFrom-StringData -stringdata @'
        AccountPolicyRule               = AccountPolicy
        AuditPolicyRule                 = AuditPolicySubcategory
        DnsServerRootHintRule           = Script
        DnsServerSettingRule            = xDnsServerSetting
        DocumentRule                    = None
        GroupRule                       = Group
        IisLoggingRule                  = xWebSite
        MimeTypeRule                    = xIisMimeTypeMapping
        ManualRule                      = None
        ProcessMitigationRule           = ProcessMitigation
        RegistryRule                    = xRegistry, cAdministratorTemplate #jjs
        SecurityOptionRule              = SecurityOption
        ServiceRule                     = xService
        SqlScriptQueryRule              = SqlScriptQuery
        UserRightRule                   = UserRightsAssignment
        WebAppPoolRule                  = xWebAppPool
        WebConfigurationPropertyRule    = xWebConfigKeyValue
        WindowsFeatureRule              = WindowsFeature
        WinEventLogRule                 = xWinEventLog
        WmiRule                         = Script
'@
}
#jjs need to address RegistryRule between xRegistry and cAdministratorTemplate