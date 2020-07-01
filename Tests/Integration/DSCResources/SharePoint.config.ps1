configuration SharePoint_config
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [AllowNull()]
        [string]
        $TechnologyVersion,

        [Parameter()]
        [AllowNull()]
        [string]
        $TechnologyRole,

        [Parameter(Mandatory = $true)]
        [string]
        $StigVersion,

        [Parameter()]
        [hashtable]
        $Exception,

        [Parameter()]
        [hashtable]
        $BackwardCompatibilityException,

        [Parameter()]
        [string[]]
        $SkipRule,

        [Parameter()]
        [string[]]
        $SkipRuleType,

        [Parameter()]
        [object]
        $OrgSettings,

        [Parameter()]
        [string]
        $WebAppUrl,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [pscredential]
        $SetupAccount
    )

    Import-DscResource -ModuleName PowerStig

    Node localhost
    {
        SharePoint Configuration
        {
            SharePointVersion   = $TechnologyVersion
            SetupAccount        = $SetupAccount
            WebAppUrl           = 'test.com'
        }
    }
}
