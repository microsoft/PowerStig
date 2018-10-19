Configuration Browser_config
{
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $BrowserVersion,

        [Parameter(Mandatory = $true)]
        [string]
        $StigVersion
    )

    Import-DscResource -ModuleName PowerStig

    Node localhost
    {
        Browser InternetExplorer
        {
            BrowserVersion = $browserVersion
            Stigversion    = $stigVersion
        }
    }
}
