Configuration SqlServerInstance_config
{
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $SqlVersion,

        [Parameter(Mandatory = $true)]
        [string]
        $SqlRole,

        [Parameter()]
        [string]
        $StigVersion
    )

    Import-DscResource -ModuleName PowerStig -ModuleVersion 2.3.1.0

    Node localhost
    {
        SqlServer Instance
        {
            SqlVersion     = $SqlVersion
            SqlRole        = $SqlRole
            Stigversion    = $StigVersion
            ServerInstance = 'TestServer'
        }
    }
}

Configuration SqlServerDatabase_config
{
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $SqlVersion,

        [Parameter(Mandatory = $true)]
        [string]
        $SqlRole,

        [Parameter()]
        [string]
        $StigVersion
    )

    Import-DscResource -ModuleName PowerStig -ModuleVersion 2.3.1.0

    Node localhost
    {
        SqlServer Database
        {
            SqlVersion     = $SqlVersion
            SqlRole        = $SqlRole
            Stigversion    = $StigVersion
            ServerInstance = 'TestServer'
            Database       = 'TestDataBase'
        }
    }
}
