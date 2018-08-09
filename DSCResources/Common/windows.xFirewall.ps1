# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$rules = Get-RuleClassData -StigData $StigData -Name FirewallRule

Foreach( $rule in $rules )
{
    ## TO DO - Make this work
    xFirewall (Get-ResourceTitle -Rule $rule)
    {

    }
}
