# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$rules = Get-RuleClassData -StigData $StigData -Name AuditPolicyRule

Foreach ( $rule in $rules )
{
    AuditPolicySubcategory (Get-ResourceTitle -Rule $rule)
    {
        Name      = $rule.Subcategory
        AuditFlag = $rule.AuditFlag
        Ensure    = $rule.Ensure
    }
}
