<#
    .SYNOPSIS
        Apply the latest Windows Firewall STIG to a node

    .DESCRIPTION
        Use the embedded STIG data with default range values. In this example,
        the lastest Windows Firewall STIG is processed by the composite resource
        and merges in the default values for any settings that have a valid range.
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
        { }
    }
}

Example
