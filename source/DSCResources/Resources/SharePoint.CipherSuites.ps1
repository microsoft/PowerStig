# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$rules = Select-Rule -Type CipherSuitesRule -RuleList $stig.RuleList

foreach ($rule in $rules)
{
    CipherSuites (Get-ResourceTitle -Rule $rule)
    {
        IsSingleInstance        = 'Yes'
        CipherSuitesOrder       = $CipherSuitesOrder
        Ensure                  = "Present"
        PsDscRunAsCredential    = $SetupAccount
    }
}