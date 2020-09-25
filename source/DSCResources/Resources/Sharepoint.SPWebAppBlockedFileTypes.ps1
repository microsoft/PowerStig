# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$rules = Select-Rule -Type SPWebAppBlockedFileTypesRule -RuleList $stig.RuleList

foreach ($rule in $rules)
{
    SPWebAppBlockedFileTypes (Get-ResourceTitle -Rule $rule)
    {
        WebAppUrl               = $WebAppUrl
        CipherSuitesOrder       = $BlockedFileTypes
        Ensure                  = "Present"
        PsDscRunAsCredential    = $SetupAccount
    }
}
