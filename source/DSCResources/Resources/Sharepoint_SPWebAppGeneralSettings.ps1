# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$rules = $stig.RuleList | Select-Rule -Type SharePoint_SPWebAppGeneralSettingsRule

foreach ($rule in $rules)
{
    SharePoint_SPWebAppGeneralSettings (Get-ResourceTitle -Rule $rule)
    {

        <#
        add a switch statement
        the switch needs to pick between different combinations of properties + values
        the combos are based on 
        the result should be "okay, you want this combination of properties to be sent out"
        #>

        switch ($x) {
            condition {  }
            Default {}
        }

        Name = $rule.Name
        Ensure = $rule.Ensure
        WebAppUrl = $rule.WebAppUrl
        BrowserFileHandling = $rule.BrowserFileHandling
        SecurityValidationTimeOutMinutes = $rule.SecurityValidationTimeOutMinutes
        AllowOnlineWebPartCatalog = $rule.AllowOnlineWebPartCatalog
    }
}