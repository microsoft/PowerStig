Configuration Outlook2013_config
{
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $Outlook2013,

        [Parameter(Mandatory = $true)]
        [version]
        $StigVersion
    )

    Import-DscResource -ModuleName PowerStig

    Node localhost
    {
        Outlook2013 BaseLineSettings
        {
            Outlook2013 = $Outlook2013
            StigVersion = $StigVersion
        }
    }
}
