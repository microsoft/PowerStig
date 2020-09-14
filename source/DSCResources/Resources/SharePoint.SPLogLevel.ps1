# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$rules = Select-Rule -Type SharePointSPLogLevelRule -RuleList $stig.RuleList

foreach ($rule in $rules)
{
    SPLogLevel (Get-ResourceTitle -Rule $rule)
    {
        Name = "CustomLoggingSettingsByPowerSTIG"
        SPLogLevelSetting = @(
            foreach ($SPLogLevelItem in $SPLogLevelItems)
            {
                MSFT_SPLogLevelItem {
                    foreach ($key in $SPLogLevelItem.Keys)
                    {
                        "$key = $($SPLogLevelItem[$key])"
                    }
                }
            }
        )
        PsDscRunAsCredential = $SetupAccount
    }
}