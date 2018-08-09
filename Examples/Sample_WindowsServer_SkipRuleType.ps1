<#
    .SYNOPSIS
        Apply the Windows Server STIG to a node, but skip an entire class of rules

    .DESCRIPTION
        Use embedded STIG data and skip an entire rule set. In this example, the
        Windows Server 2012R2 V2 R12 domain controller STIG is processed by the
        composite resource and merges in the default values for any settings that
        have a valid range. Additionally, a skip is added inline to the
        configuration, so that the setting for all STIG ID's with the type
        'AuditPolicyRule' would be marked to skip configuration when applied.
#>
configuration Example
{
    param
    (
        [parameter()]
        [string]
        $NodeName = 'localhost'
    )

    Import-DscResource -ModuleName PowerStig

    Node $NodeName
    {
        WindowsServer BaseLine
        {
            OsVersion    = '2012R2'
            OsRole       = 'MS'
            StigVersion  = '2.12'
            DomainName   = 'sample.test'
            ForestName   = 'sample.test'
            SkipRuleType = 'AuditPolicyRule'
        }
    }
}

Example
