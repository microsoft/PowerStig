# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$rules = Select-Rule -Type SPWebAppBlockedFileTypesRule -RuleList $stig.RuleList

foreach ($rule in $rules)
{
    foreach ($WebApp in $WebAppUrlandBlockedFileTypesList)
    {
        $resourceTitle = (Get-ResourceTitle -Rule $rule) + "::[" + "$($WebApp['WebAppUrl'])]"
        SPWebAppBlockedFileTypes $resourceTitle
        {
            WebAppUrl               = $WebApp['WebAppUrl']
            Blocked                 = $WebApp['List']
            PsDscRunAsCredential    = $SetupAccount
        }
    }
}
