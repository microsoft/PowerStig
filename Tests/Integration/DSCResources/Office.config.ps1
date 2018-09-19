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

    Import-DscResource -ModuleName PowerStig -ModuleVersion 2.1.0.0

    Node localhost
    {
        Office BaseLineSettings
        {
            OfficeApp   = $OfficeApp
            StigVersion = $StigVersion
        }
    }
}
