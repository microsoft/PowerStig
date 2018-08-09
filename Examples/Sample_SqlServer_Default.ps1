<#
    Use the embedded STIG data with default range values.
    In this example, the Windows SQL Server 2012 V1 R17 STIG is processed by the
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

    Node localhost
    {
        SqlServer BaseLine
        {
            SqlVersion     = '2012'
            SqlRole        = 'Instance'
            StigVersion    = '1.17'
            ServerInstance = 'ServerX\TestInstance'
        }
    }
}

Example
