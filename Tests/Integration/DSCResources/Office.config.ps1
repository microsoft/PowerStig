Configuration Office_config
{
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $OfficeApp,

        [Parameter(Mandatory = $true)]
        [version]
        $StigVersion
    )

    Import-DscResource -ModuleName PowerStig

    Node localhost
    {
        Office BaseLineSettings
        {
            OfficeApp   = $OfficeApp
            StigVersion = $StigVersion
        }
    }
}