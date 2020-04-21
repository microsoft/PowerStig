# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$rules = $stig.RuleList | Select-Rule -Type 'VsphereVssSecurityRule'

foreach ($virtualStandardSwitch in $virtualStandardSwitchGroup)
{
    foreach ($rule in $rules)
    {
        If ($rule.AllowPromiscuous)
        {
            $AllowPromiscuous = $rule.AllowPromiscuous
        }
        If ($rule.ForgedTransmits)
        {
            $ForgedTransmits = $rule.ForgedTransmits
        }
        If ($rule.MacChanges)
        {
            $MacChanges = $rule.MacChanges
        }

        $idValue += $rule.id
    }

    VmHostVssSecurity "$virtualStandardSwitch-$idValue"
    {
        Name             = $HostIP
        Server           = $ServerIP
        Credential       = $Credential
        VssName          = $VirtualStandardSwitch
        AllowPromiscuous = [bool] $AllowPromiscuous
        ForgedTransmits  = [bool] $ForgedTransmits
        MacChanges       = [bool] $MacChanges
        Ensure           = 'Present'
    }
}
