# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$rules = $stig.RuleList | Select-Rule -Type WindowsFeatureRule

foreach ( $rule in $rules )
{
    <#
        This is here to address the issue that WindowsOptionalFeature is writen
        to not run on a DC, and WindowsFeature does not run on client OS. In the
        future if WindowsOptionalFeature is updated to allow it to run a on DC
        lines 17-31 can be removed.
    #>
    if ($rule.FeatureName -eq 'SMB1Protocol')
    {
        $rule.FeatureName = 'FS-SMB1'
    }

    xWindowsFeature (Get-ResourceTitle -Rule $rule)
    {
        Name   = $rule.FeatureName
        Ensure = $rule.InstallState
    }
}
