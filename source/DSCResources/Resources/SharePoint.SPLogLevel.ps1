# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$rules = Select-Rule -Type SPLogLevelRule -RuleList $stig.RuleList

foreach ($rule in $rules)
{
    SPLogLevel (Get-ResourceTitle -Rule $rule)
    {
        Name = "CustomLoggingSettingsByPowerSTIG"
        SPLogLevelSetting = @(
            foreach ($LogLevelItem in $SPLogLevelItem)
            {
                MSFT_SPLogLevelItem {
                    Name       = $LogLevelItem['Name']
                    Area       = $LogLevelItem['Area']
                    EventLevel = $LogLevelItem['EventLevel']
                    TraceLevel = $LogLevelItem['TraceLevel']
                }
            }
        )
        PsDscRunAsCredential = $SetupAccount
    }
}
