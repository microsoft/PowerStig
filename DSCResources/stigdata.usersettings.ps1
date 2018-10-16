<#
    This file is dot sourced into every composite. It processes the exceptions,
    skipped rules, and organizational objects that were provided to the composite
    and converts them into the approperate class for the StigData class constructor
#>
Switch ($PSCmdlet.MyInvocation.BoundParameters.Keys)
{
    'Exception'
    {
        $exception = [StigException]::ConvertFrom( $exception )
    }
    'SkipRule'
    {
        $skipRule = [SkippedRule]::ConvertFrom( $skipRule )
    }
    'SkipRuleType'
    {
        $skipRuleType = [SkippedRuleType]::ConvertFrom( $skipRuleType )
    }
    'OrgSettings'
    {
        $orgSettings = Get-OrgSettingsObject -OrgSettings $orgSettings
    }
}
