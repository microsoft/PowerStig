# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$rules = $stig.RuleList | Select-Rule -Type 'VsphereServiceRule'

foreach ( $rule in $rules )
{
    VmHostService (Get-ResourceTitle -Rule $rule)
    {
        Name = $VsphereHostIP
        Server = $VcenterServerIP
        Credential = $VsphereCredential
        Running =  $rule.Running
        Key =  $rule.Name
        Policy =  $rule.Policy
    }
}
