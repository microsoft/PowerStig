# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

data xmlAttribute
{
    ConvertFrom-StringData -stringdata @'
        stigId             = id
        stigVersion        = version
        stigConvertCreated = created

        ruleId                = id
        ruleSeverity          = severity
        ruleConversionStatus  = conversionstatus
        ruleTitle             = title
        ruleDscResource       = dscresource
        ruleDscResourceModule = dscresourcemodule

        organizationalSettingValue = value
'@
}

data xmlElement
{
    ConvertFrom-StringData -stringdata @'
        stigConvertRoot = DISASTIG

        organizationalSettingRoot  = OrganizationalSettings
        organizationalSettingChild = OrganizationalSetting
'@
}

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
