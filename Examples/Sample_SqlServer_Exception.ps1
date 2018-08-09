<#
    Use the embedded STIG data with default range values.
    In this example, the Windows SQL Server 2012 V1 R17 STIG is processed by the
    composite resource and merges in the default values for any settings that have a valid range.
    Additionally, an exception is added inline
    to the configuration, so that the setting in STIG ID V-1000 would be over
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

    Node localhost
    {
        SqlServer BaseLine
        {
            SqlVersion     = '2012'
            SqlRole        = 'Instance'
            StigVersion    = '1.17'
            ServerInstance = 'ServerX\TestInstance'
            Exception      = @{'V-40942'= @{'GetScript'="SELECT name from sysdatabases where name like 'DefaultDataBase'"} }
        }
    }
}

Example
