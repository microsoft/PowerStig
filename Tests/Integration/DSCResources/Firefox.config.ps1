Configuration Firefox_config
{
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $StigVersion
    )

    Import-DscResource -ModuleName PowerStig -ModuleVersion 2.1.0.0

    Node localhost
    {
        Firefox Firefox
        {
            Stigversion    = $StigVersion
        }
    }
}