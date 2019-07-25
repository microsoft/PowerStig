configuration sqlInstance
{
    Import-DscResource -ModuleName PowerSTIG

    node localhost
    {
        SqlServer NewSaName
        {
            SqlVersion = '2012'
            Sqlrole = 'Instance'
            ServerInstance = 'SqlStig\SMA'
        }
    }
}

sqlInstance -OutputPath c:\dsc
