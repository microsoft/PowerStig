# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$rules = $stig.RuleList | Select-Rule -Type 'VsphereSnmpAgentRule'

foreach ( $rule in $rules )
{
    VmHostSnmpAgent (Get-ResourceTitle -Rule $rule)
    {
        Name = $VsphereHostIP
        Server = $VcenterServerIP
        Credential = $VsphereCredential
        Enable =  $rule.Enabled
    }
}
