# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$rules = $stig.RuleList | Select-Rule -Type 'VspherePortGroupSecurityRule'

foreach ($vm in $vmGroup)
{
    foreach ($rule in $rules)
    {
        If ($rule.AllowPromiscuous)
        {
            $AllowPromiscuousInherited = $rule.AllowPromiscuousInherited 
        }
        If ($rule.ForgedTransmits)
        {
            $ForgedTransmitsInherited  = $rule.ForgedTransmitsInherited 
        }
        If ($rule.MacChanges)
        {
            $MacChangesInherited  = $rule.MacChangesInherited 
        }

        $idValue += $rule.id
    }

    VmHostVssPortGroupSecurity "$vm-$idValue"
    {
        Name                      = $HostIP
        Server                    = $ServerIP
        Credential                = $Credential
        VmHostName                = $vm
        AllowPromiscuousInherited = [bool] $AllowPromiscuousInherited
        ForgedTransmitsInherited  = [bool] $ForgedTransmitsInherited
        MacChangesInherited       = [bool] $MacChangesInherited
        Ensure                    = 'Present'
    }
}
