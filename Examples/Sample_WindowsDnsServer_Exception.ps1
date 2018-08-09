<#
    .SYNOPSIS
        Apply the Windows DNS Server STIG to a node, but override the value of V-58697.a

    .DESCRIPTION
        Use embedded STIG data and inject exception data. In this example, the
        Windows DNS Server 2012 R2 V1 R9 STIG is processed by the composite
        resource and merges in the default values for any settings that have a
        valid range. Additionally, an exception is added inline to the
        configuration, so that the setting Identity in STIG ID V-58697.a would
        be over written with the value @('Administrators,DnsAdministrators').
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
            OsVersion   = '2012R2'
            StigVersion = '1.9'
            DomainName  = 'integation.test'
            ForestName  = 'integation.test'
            Exception   = @{"V-58697.a" = @{'Identity'='Administrators,DnsAdministrators'}}
        }
    }
}

Example
