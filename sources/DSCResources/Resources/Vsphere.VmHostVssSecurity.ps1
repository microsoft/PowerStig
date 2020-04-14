# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$rules = $stig.RuleList | Select-Rule -Type 'VsphereVssSecurityRule'

foreach ($virtualStandardSwitch in $virtualStandardSwitchGroup)
{
    foreach ($rule in $rules)
    {
        VmHostVssSecurity (Get-ResourceTitle -Rule $rule)
        {
            Name             = $HostIP
            Server           = $ServerIP
            Credential       = $Credential
            VssName          = $VirtualStandardSwitch
            AllowPromiscuous = $rule.AllowPromiscuous
            ForgedTransmits  = $rule.ForgedTransmits
            MacChanges       = $rule.MacChanges
        }
    }
}
