<#
    Use the embedded STIG data with default range values.
    In this example, the Windows Firewall V1 R6 STIG is processed by the
    composite resource and merges in the default values for any settings
    that have a valid range.
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
            StigVersion = '1.6'
        }
    }
}

Example
