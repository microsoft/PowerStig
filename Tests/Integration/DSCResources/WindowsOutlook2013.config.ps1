Configuration WindowsOutlook2013_config
{
    param
    (
        [Parameter(Mandatory = $true)]
        [version]
        $StigVersion
    )

    Import-DscResource -ModuleName PowerStig

    Node localhost
    {
        WindowsOutlook2013 BaseLineSettings
        {
            StigVersion = $StigVersion
        }
    }
}
