# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$rules = $stig.RuleList | Select-Rule -Type 'VsphereVssSecurityRule'

foreach ( $VirtualStandardSwitch in $VirtualStandardSwitchGroup )
{
    foreach ( $rule in $rules )
    {
        VmHostVssSecurity (Get-ResourceTitle -Rule $rule)
        {
            Name = $VsphereHostIP
            Server = $VcenterServerIP
            Credential = $VsphereCredential
            VssName = $VirtualStandardSwitch
            AllowPromiscuous =  $rule.AllowPromiscuous
            ForgedTransmits = $rule.ForgedTransmits
            MacChanges = $rule.MacChanges
        }
    }
}
