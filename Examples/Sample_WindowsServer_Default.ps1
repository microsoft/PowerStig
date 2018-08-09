<#
    .SYNOPSIS
        Apply the latest Windows Server STIG to a node

    .DESCRIPTION
        Use the embedded STIG data with default range values to apply the most
        recent STIG settings. In this example, the composite resource gets the
        highest 2012 R2 member server STIG version file it can find and applies
        it to the server. The composite resource merges in the default values
        for any settings that have a valid range.
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
            DomainName  = 'sample.test'
            ForestName  = 'sample.test'
        }
    }
}

Example
