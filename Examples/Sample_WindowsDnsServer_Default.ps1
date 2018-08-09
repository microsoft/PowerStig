<#
    Use the embedded STIG data with default range values.
    In this example, the Windows DNS Server 2012 R2 V1 R7 STIG is processed by the
    composite resource and merges in the default values for any settings that have a valid range.
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
        }
    }
}

Example
