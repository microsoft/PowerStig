<#
    .SYNOPSIS
        Apply the Windows SQL Server STIG to a node, but skip SqlScriptQueryRule

    .DESCRIPTION
        Use the embedded STIG data with default range values. In this example,
        the SQL Server 2012 V1 R1 STIG is processed by the composite resource
        and merges in the default values for any settings that have a valid range.
        Additionally, a skip is added inline to the configuration, so that the
        settings for all STIG ID's with the type 'SqlScriptQueryRule' would be
        marked to skip configuration when applied.
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
            StigVersion    = '1.16'
            ServerInstance = 'ServerX\TestInstance'
            SkipRuleType   = 'SqlScriptQueryRule'
        }
    }
}

Example
