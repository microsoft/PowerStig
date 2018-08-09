<#
    .SYNOPSIS
        Apply the Windows Server STIG to a node, but override a rule value

    .DESCRIPTION
        Use embedded STIG data and inject exception data. In this example, the
        Windows Server 2012R2 V2 R12 domain controller STIG is processed by the
        composite resource and merges in the default values for any settings
        that have a valid range. Additionally, an exception is added inline to
        the configuration, so that the setting in STIG ID V-1075 would be over
        written with the value 1.
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
            Exception   = @{'V-1075'= @{'ValueData'='1'} }
        }
    }
}

Example
