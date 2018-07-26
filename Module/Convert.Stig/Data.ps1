# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

data DscResourceModule
{
    ConvertFrom-StringData -stringdata @'
        AccountPolicyRule               = SecurityPolicyDsc
        AuditPolicyRule                 = AuditPolicyDsc
        DnsServerSettingRule            = xDnsServer
        DnsServerRootHintRule           = PSDesiredStateConfiguration
        DocumentRule                    = None
        IisLoggingRule                  = xWebAdministration
        MimeTypeRule                    = xWebAdministration
        ManualRule                      = None
        PermissionRule                  = AccessControlDsc
        ProcessMitigationRule           = ProcessMitigationDsc
        RegistryRule                    = PSDesiredStateConfiguration
        SecurityOptionRule              = SecurityPolicyDsc
        ServiceRule                     = xPSDesiredStateConfiguration
        SqlScriptQueryRule              = SqlServerDsc
        UserRightRule                   = SecurityPolicyDsc
        WebAppPoolRule                  = xWebAdministration
        WebConfigurationPropertyRule    = xWebAdministration
        WindowsFeatureRule              = PSDesiredStateConfiguration
        WinEventLogRule                 = xWinEventLog
        WmiRule                         = PSDesiredStateConfiguration
'@
}

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
        RegistryRule                    = Registry
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
