<#
    This file is dot sourced into every composite. It processes the exceptions,
    skipped rules, and organizational objects that were provided to the composite
    and converts them into the approperate class for the StigData class constructor
#>
Switch ($PSCmdlet.MyInvocation.BoundParameters.Keys)
{
    'Exception'
    {
        $Exception = [StigException]::ConvertFrom( $Exception )
    }
    'SkipRule'
    {
        $SkipRule = [SkippedRule]::ConvertFrom( $SkipRule )
    }
    'SkipRuleType'
    {
        $SkipRuleType = [SkippedRuleType]::ConvertFrom( $SkipRuleType )
    }
    'OrgSettings'
    {
        $OrgSettings = Get-OrgSettingsObject -OrgSettings $OrgSettings
    }
}
