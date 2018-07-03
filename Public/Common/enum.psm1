# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

<#
    STIGS have an associated severity that determines the impact of the findhing if it
    is not configured properly
#>
enum severity
{
    low
    medium
    high
}

<#
    The status enum is used to display the status of the STIG item processing
#>
enum status
{
    pass
    warn
    fail
}

enum RuleType
{
    AccountPolicyRule
    AuditPolicyRule
    DnsServerRootHintRule
    DnsServerSettingRule
    DocumentRule
    GroupRule
    IisLoggingRule
    ManualRule
    MimeTypeRule
    PermissionRule
    ProcessMitigationRule
    RegistryRule
    SecurityOptionRule
    ServiceRule
    SqlScriptQueryRule
    UserRightRule
    WebAppPoolRule
    WebConfigurationPropertyRule
    WindowsFeatureRule
    WinEventLogRule
    WmiRule
}
<#
    The process enum is used as a flag for further automation. The intent is that if a STIG
    has been fully process, then the setting can be automatically published to a server. If
    a setting has not been fully process then it needs to be manually processed. This is
    differnt from the status enum in that status is a control flag to descrive the state
    of the item processing
#>
enum process
{
    auto
    manual
}

enum ensure
{
    Present
    Absent
}
