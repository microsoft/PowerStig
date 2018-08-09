<#
    .SYNOPSIS
        Apply the Windows Firewall STIG to a node, but skip the ManualRule

    .DESCRIPTION
        Use embedded STIG data and skip an entire rule set. In this example, the
        Windows Firewall V1 R6 STIG is processed by the composite resource and
        merges in the default values for any settings that have a valid range.
        Additionally, a skip is added inline to the configuration, so that the
        setting for all STIG ID's with the type 'ManualRule' would be
        marked to skip configuration when applied.
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
        WindowsFirewall EnterpriseFirewallPolicy
        {
            StigVersion  = '1.6'
            SkipRuleType = 'ManualRule'
        }
    }
}

Example
