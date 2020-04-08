# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$rules = $stig.RuleList | Select-Rule -Type SharePoint.SPIrmSettingsRule

foreach ($rule in $rules)
{
    SPIrmSettings (Get-ResourceTitle -Rule $rule)
    {
        IsSingleInstance = $rule.IsSingleInstance
        Ensure = $rule.Ensure
        UseADRMS = $rule.UseADRMS
        RMSserver = $rule.RMSserver
        InstallAccount = $rule.InstallAccount
    }
}