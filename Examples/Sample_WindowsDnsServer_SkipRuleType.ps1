<#
    .SYNOPSIS
        Apply the Windows DNS Server STIG to a node, but skip all UserRightRules

    .DESCRIPTION
        Use embedded STIG data and skip an entire rule set. In this example, the
        Windows DNS Server 2012 R2 V1 R7 STIG is processed by the composite
        resource and merges in the default values for any settings that have a
        valid range. Additionally, a skip is added inline to the configuration,
        so that the setting for all STIG ID's with the type 'UserRightRule'
        would be marked to skip configuration when applied.
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
        WindowsDnsServer DnsSettings
        {
            OsVersion    = '2012R2'
            StigVersion  = '1.7'
            DomainName   = 'integation.test'
            ForestName   = 'integation.test'
            SkipRuleType = 'UserRightRule'
        }
    }
}

Example
