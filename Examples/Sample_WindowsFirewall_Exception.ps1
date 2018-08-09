<#
    .SYNOPSIS
        Apply the Windows Firewall STIG to a node, but override the value of V-17415.a

    .DESCRIPTION
        Use embedded STIG data and inject exception data. In this example, the
        Windows Firewall V1 R6 STIG is processed by the composite resource and
        merges in the default values for any settings that have a valid range.
        Additionally, an exception is added inline to the configuration, so that
        the setting in STIG ID V-17415.a would be over written with the value 0.
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
        WindowsFirewall Sample_WindowsFirewall_Exception
        {
            StigVersion = '1.6'
            Exception   = @{'V-17415.a'= @{'ValueData'='0'}}
        }
    }
}

Example
