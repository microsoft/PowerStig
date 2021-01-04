# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$rules = Select-Rule -RuleList $stig.RuleList -Type RootCertificateRule

foreach ($rule in $rules)
{
    if ($rule.CertificateName -match "Interoperability")
    {
        $storeLocation = 'Disallowed'
    }
    else
    {
        $storeLocation = 'Root'
    }

    CertificateImport (Get-ResourceTitle -Rule $rule)
    {
        Thumbprint = $rule.Thumbprint
        Location   = 'LocalMachine'
        Store      = $storeLocation
        Path       = $rule.Location
    }
}
