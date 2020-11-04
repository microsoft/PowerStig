# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$rules = $stig.RuleList | Select-Rule -Type RootCertificateRule

foreach ( $rule in $rules )
{
    if($rule.Name -contains "Interoperability")
    {
        CertificateImport (Get-ResourceTitle -Rule $rule)
        {
            Thumbprint = $rule.Thumbprint
            Location   = 'LocalMachine'
            Store      = 'Disallowed'
            Path       = $rule.Location
        }
    }
    else
    {
        CertificateImport (Get-ResourceTitle -Rule $rule)
        {
            Thumbprint = $rule.Thumbprint
            Location   = 'LocalMachine'
            Store      = 'Root'
            Path       = $rule.Location
        }
    }
}
