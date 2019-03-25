# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

data xmlAttribute
{
    ConvertFrom-StringData -StringData @'
        ruleId                = id
        ruleSeverity          = severity
        ruleConversionStatus  = conversionstatus
        ruleTitle             = title
        ruleDscResource       = dscresource
        ruleDscResourceModule = dscresourcemodule

        organizationalSettingValue = value
'@
}

data dscResourceModule
{
    ConvertFrom-StringData -StringData @'
        AccountPolicyRule               = SecurityPolicyDsc
        AuditPolicyRule                 = AuditPolicyDsc
        DnsServerSettingRule            = xDnsServer
        DnsServerRootHintRule           = xPSDesiredStateConfiguration
        DocumentRule                    = None
        GroupRule                       = PSDesiredStateConfiguration
        IisLoggingRule                  = xWebAdministration
        MimeTypeRule                    = xWebAdministration
        ManualRule                      = None
        PermissionRule                  = AccessControlDsc
        ProcessMitigationRule           = WindowsDefenderDsc
        RegistryRule                    = xPSDesiredStateConfiguration
        SecurityOptionRule              = SecurityPolicyDsc
        ServiceRule                     = xPSDesiredStateConfiguration
        SqlScriptQueryRule              = SqlServerDsc
        UserRightRule                   = SecurityPolicyDsc
        WebAppPoolRule                  = xWebAdministration
        WebConfigurationPropertyRule    = xWebAdministration
        WindowsFeatureRule              = PSDesiredStateConfiguration
        WinEventLogRule                 = xWinEventLog
        SslSettingsRule                 = xWebAdministration
        WmiRule                         = xPSDesiredStateConfiguration
        FileContentRule                 = FileContentDsc
'@
}
