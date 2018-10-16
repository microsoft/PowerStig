Configuration Office_config
{
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $OfficeApp,

        [Parameter(Mandatory = $true)]
        [version]
        $stigVersion
    )

    Import-DscResource -ModuleName PowerStig

    Node localhost
    {
        Office BaseLineSettings
        {
            OfficeApp   = $OfficeApp
            StigVersion = $stigVersion
        }
    }
}
