<#
    .SYNOPSIS
        Apply the SQL Server STIG to a node, but skip V-V-40942

    .DESCRIPTION
        Use the embedded STIG data with default range values. In this example,
        the SQL Server 2012 V1 R17 STIG is processed by the composite resource
        and merges in the default values for any settings that have a valid range.
        Additionally, a skip is added inline to the configuration, so that the
        setting in STIG ID V-V-40942 would be marked to skip configuration when
        applied.
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
            SkipRule       = 'V-40942'
        }
    }
}

Example
