# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$rules = $stig.RuleList | Select-Rule -Type 'VspherePortGroupSecurityRule'

foreach ($vm in $vmGroup)
{
    foreach ($rule in $rules)
    {
        VmHostVssPortGroupSecurity (Get-ResourceTitle -Rule $rule)
        {
            Name                      = $HostIP
            Server                    = $ServerIP
            Credential                = $Credential
            VmHostName                = $vm
            AllowPromiscuousInherited = $rule.AllowPromiscuousInherited
            ForgedTransmitsInherited  = $rule.ForgedTransmitsInherited
            MacChangesInherited       = $rule.MacChangesInherited
        }
    }
}
