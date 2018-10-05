Configuration Firefox_config
{
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $StigVersion
    )

    Import-DscResource -ModuleName PowerStig

    Node localhost
    {
        Firefox Firefox
        {
            Stigversion = $StigVersion
        }
    }
}
