# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$rules = $stig.RuleList | Select-Rule -Type 'VsphereKernelActiveDumpPartitionRule'

foreach ( $rule in $rules )
{
    VmHostVMKernelActiveDumpPartition (Get-ResourceTitle -Rule $rule)
    {
        Name = $VsphereHostIP
        Server = $VcenterServerIP
        Credential = $VsphereCredential
        Enable =  $rule.Enabled
    }
}
