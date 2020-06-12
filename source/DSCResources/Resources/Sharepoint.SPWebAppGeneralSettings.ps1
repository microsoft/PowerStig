# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$rules = Select-Rule -Type SharePointSPWebAppGeneralSettingsRule -RuleList $stig.RuleList

foreach ($rule in $rules)
{
    $ruleTitle = Get-ResourceTitle -Rule $rule
    $spWebAppGenSettingsStringBuilder = New-Object -TypeName System.Text.StringBuilder
    $spWebAppGenSettingsStringBuilder.AppendLine("SPWebAppGeneralSettings $ruleTitle`n{")
    $spWebAppGenSettingsStringBuilder.AppendLine("WebAppUrl = $WebAppUrl")
    $spWebAppGenSettingsStringBuilder.AppendLine("$($rule.PropertyName) = $($rule.PropertyValue)")
    $spWebAppGenSettingsStringBuilder.AppendLine('PsDscRunAsCredential = $SetupAccount')
    $spWebAppGenSettingsStringBuilder.AppendLine('}')
    $spWebAppGenSettingsScriptBlock = [scriptblock]::Create($spWebAppGenSettingsStringBuilder.ToString())
    & $spWebAppGenSettingsScriptBlock

    <#
        switch ($rule.PropertyName)
    {   
        'SecurityValidation'
        {
            SPWebAppGeneralSettings (Get-ResourceTitle -Rule $rule)
            {
                WebAppUrl               = $WebAppUrl
                SecurityValidation      = $rule.PropertyValue 
                PsDscRunAsCredential    = $SetupAccount
            }
        }
        
        'SecurityValidationTimeOutMinutes'
        {
            SPWebAppGeneralSettings (Get-ResourceTitle -Rule $rule)
            {
                WebAppUrl                           = $WebAppUrl
                SecurityValidationTimeOutMinutes    = $rule.PropertyValue 
                PsDscRunAsCredential                = $SetupAccount
            }
        }

        'BrowserFileHandling'
        {
            SPWebAppGeneralSettings (Get-ResourceTitle -Rule $rule)
            {
                WebAppUrl                           = $WebAppUrl
                BrowserFileHandling                 = $rule.PropertyValue 
                PsDscRunAsCredential                = $SetupAccount
            }
        }

        'AllowOnlineWebPartCatalog'
        {
            SPWebAppGeneralSettings (Get-ResourceTitle -Rule $rule)
            {
                WebAppUrl                           = $WebAppUrl
                AllowOnlineWebPartCatalog           = $rule.PropertyValue 
                PsDscRunAsCredential                = $SetupAccount
            }
        }
    }
    #>
}