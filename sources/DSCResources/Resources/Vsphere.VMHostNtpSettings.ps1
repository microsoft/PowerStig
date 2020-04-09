# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$rules = $stig.RuleList | Select-Rule -Type 'VsphereNtpSettingsRule'

foreach ( $rule in $rules )
{
    VmHostNtpSettings (Get-ResourceTitle -Rule $rule)
    {
        Name = $VsphereHostIP
        Server = $VcenterServerIP
        Credential = $VsphereCredential
        NtpServer =  $rule.NtpServer
    }
}
