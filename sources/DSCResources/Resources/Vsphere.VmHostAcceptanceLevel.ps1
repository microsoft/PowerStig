# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$rules = $stig.RuleList | Select-Rule -Type 'VsphereAcceptanceLevelRule'

foreach ( $rule in $rules )
{
    VMHostAcceptanceLevel  (Get-ResourceTitle -Rule $rule)
    {
        Name = $VsphereHostIP
        Server = $VcenterServerIP
        Credential = $VsphereCredential
        Level =  $rule.Level
    }
}
