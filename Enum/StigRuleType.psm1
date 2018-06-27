# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

<#
.SYNOPSIS
    This enum describes a StigRuleType

.DESCRIPTION
    The StigRuleType enum describes a StigRuleType, the value of a specific type of Stig rule.

.EXAMPLE
    $stigRuleType = [StigRuleType]::AccountPolicyRule

.NOTES
    This enum requires PowerShell v5 or above.
#>
Enum StigRuleType
{
    AccountPolicyRule
    AuditPolicyRule
    DnsServerRootHintRule
    DnsServerSettingRule
    DocumentRule
    GroupRule
    IisLoggingRule
    PermissionRule
    ManualRule
    MimeTypeRule
    PermissionRule
    ProcessMitigationRule
    RegistryRule
    SecurityOptionRule
    ServiceRule
    SkipRule
    SqlScriptQueryRule
    UserRightRule
    WebAppPoolRule
    WebConfigurationPropertyRule
    WindowsFeatureRule
    WinEventLogRule
    WmiRule
}
