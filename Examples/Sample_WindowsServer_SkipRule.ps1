<#
    Use embedded STIG data and inject a skipped rule. In this example,
    the Windows Server 2012R2 V2 R8 domain controller STIG is processed
    by the composite resource and merges in the default values for any
    settings that have a valid range. Additionally, a skip is added
    inline to the configuration, so that the setting in STIG ID V-1000
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
        WindowsServer BaseLine
        {
            OsVersion   = '2012R2'
            OsRole      = 'MS'
            StigVersion = '2.12'
            DomainName  = 'sample.test'
            ForestName  = 'sample.test'
            SkipRule    = 'V-1075'
        }
    }
}

Example
