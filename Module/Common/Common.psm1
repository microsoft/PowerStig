# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
# Header

#region Enum
<#
    STIGS have an associated severity that determines the impact of the finding if it
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

<#
    The process enum is used as a flag for further automation. The intent is that if a STIG
    has been fully processed, then the setting can be automatically published to a server. If
    a setting has not been fully processed then it needs to be manually processed. This is
    different from the status enum in that status is a control flag to describe the state
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

<#
    .SYNOPSIS
        This enum describes a StigRuleType

    .DESCRIPTION
        The RuleType enum describes a StigRuleType, the value of a specific type of Stig rule.

    .EXAMPLE
        $stigRuleType = [StigRuleType]::AccountPolicyRule

    .NOTES
        This enum requires PowerShell v5 or above.
#>
Enum RuleType
{
    AccountPolicyRule
    AuditPolicyRule
    DnsServerRootHintRule
    DnsServerSettingRule
    DocumentRule
    FileContentRule
    GroupRule
    IisLoggingRule
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

<#
    .SYNOPSIS
        This enum describes the list of supported technologies
#>
enum Technology
{
    Windows
    SqlServer
    Mozilla
}

#endregion

#region RegexClass

class RegularExpression
{
    static [string[]] $TextBetweenQuotes = '["''](.*?)["'']'

    static [bool] MatchTextBetweenQuotes([string] $string)
    {
        return $string -Match [RegularExpression]::TextBetweenQuotes
    }

    static [string[]] $TextBetweenParentheses = '\(([^\)]+)\)'

    static [bool] MatchTextBetweenParentheses([string] $string)
    {
        return $string -Match [RegularExpression]::TextBetweenParentheses
    }

}
#endregion
#region Footer
foreach ($supportFile in (Get-ChildItem -Path $PSScriptRoot -Exclude $MyInvocation.MyCommand.Name))
{
    Write-Verbose "Loading $($supportFile.FullName)"
    . $supportFile.FullName
}
#endregion
Export-ModuleMember -Function '*' -Variable '*'
