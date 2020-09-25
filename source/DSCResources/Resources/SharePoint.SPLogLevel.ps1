# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$rules = Select-Rule -Type SPLogLevelRule -RuleList $stig.RuleList

foreach ($rule in $rules)
{
    SPLogLevel (Get-ResourceTitle -Rule $rule)
    {
        Name = "CustomLoggingSettingsByPowerSTIG"
        SPLogLevelSetting = @(
            foreach ($SPLogLevelItem in $SPLogLevelItems)
            {
                MSFT_SPLogLevelItem {
                    Name       = $SPLogLevelItem['Name']
                    Area       = $SPLogLevelItem['Area']
                    EventLevel = $SPLogLevelItem['EventLevel']
                    TraceLevel = $SPLogLevelItem['TraceLevel']
                }
            }
        )
        PsDscRunAsCredential = $SetupAccount
    }
}
