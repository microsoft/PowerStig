# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$rules = Select-Rule -Type SharePointSPWebAppGeneralSettingsRule -RuleList $stig.RuleList

foreach ($rule in $rules)
{
    if ($vulnIDs)
    {
        $vulnIDs += ' ' + $rule.ID
    }
    else
    {
        $vulnIDs = $rule.ID
    }
    switch ($rule.PropertyName)
    {   
        'SecurityValidation'
        {
            [bool]$SecurityValidation = [System.Convert]::ToBoolean($rule.PropertyValue)
            break
        }
        
        'SecurityValidationTimeOutMinutes'
        {
            [int]$SecurityValidationTimeOutMinutes = $rule.PropertyValue 
            break
        }

        'BrowserFileHandling'
        {
            [string]$BrowserFileHandling = $rule.PropertyValue
            break
        }

        'AllowOnlineWebPartCatalog'
        {
            [bool]$AllowOnlineWebPartCatalog = [System.Convert]::ToBoolean($rule.PropertyValue)
            break
        }
    }
}
$blockTitle = "[$($vulnIDs)]"
SPWebAppGeneralSettings $blockTitle
{
    WebAppUrl                           = "$WebAppUrl"
    AllowOnlineWebPartCatalog           = $AllowOnlineWebPartCatalog
    BrowserFileHandling                 = "$BrowserFileHandling"
    SecurityValidationTimeOutMinutes    = $SecurityValidationTimeOutMinutes
    SecurityValidation                  = $SecurityValidation    
    PsDscRunAsCredential                = $SetupAccount
}

