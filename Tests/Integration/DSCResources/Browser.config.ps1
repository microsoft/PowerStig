Configuration Browser_config
{
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $browserVersion,

        [Parameter(Mandatory = $true)]
        [string]
        $stigVersion
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
