# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$rules = $stig.RuleList | Select-Rule -Type SharePoint_SPWebAppGeneralSettingsRule

foreach ($rule in $rules)
{
    #$rule.WebAppUrl
    WebAppUrl = 'http://example.contoso.local'
    switch ($rule.PropertyName)
    {   
        'SecurityValidation'
        {
            SecurityValidation = $rule.PropertyValue
        }
        
        'SecurityValidationTimeOutMinutes'
        {
            SecurityValidationTimeOutMinutes = $rule.PropertyValue
        }

        'BrowserFileHandling'
        {
            BrowserFileHandling = $rule.PropertyValue
        }

        'AllowOnlineWebPartCatalog'
        {
            AllowOnlineWebPartCatalog = $rule.PropertyValue
        }
    }
}