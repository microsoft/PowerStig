# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$rules = Get-RuleClassData -StigData $stigData -Name AccountPolicyRule

foreach ( $rule in $rules )
{
    $policy = $rule.PolicyName -replace "(:)*\s","_"

    $scriptblock = [scriptblock]::Create("
        AccountPolicy '$(Get-ResourceTitle -Rule $rule)'
        {
            Name = '$policy'
            $policy = '$($rule.PolicyValue)'
        }"
    )

    $scriptblock.Invoke()
}
