# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$rules = Get-RuleClassData -StigData $StigData -Name DnsServerSettingRule

Foreach ( $rule in $rules )
{
    $scriptblock = ([scriptblock]::Create("
        xDnsServerSetting  '$(Get-ResourceTitle -Rule $rule)'
        {
            Name = '$($rule.PropertyName)'
            $($rule.PropertyName)  = $($rule.PropertyValue)
        }")
    )

    $scriptblock.Invoke()
}
