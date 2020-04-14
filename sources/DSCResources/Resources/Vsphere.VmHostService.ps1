# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$rules = $stig.RuleList | Select-Rule -Type 'VsphereServiceRule'

foreach ( $rule in $rules )
{
    VmHostService (Get-ResourceTitle -Rule $rule)
    {
        Name = $HostIP
        Server = $ServerIP
        Credential = $Credential
        Running =  $rule.ServiceRunning
        Key =  $rule.ServiceName
        Policy =  $rule.ServicePolicy
    }
}
