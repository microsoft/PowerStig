# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$rules = Get-RuleClassData -StigData $StigData -Name SkipRule

if ($rules)
{
    foreach ( $rule in $rules )
    {
        Script (Get-ResourceTitle -Rule $rule)
        {
            <#
                This is left blank because we are only using the script resource as an audit tool for
                STIG items that should be part of an orchestration function and not configuration.
            #>
            GetScript = {
                Return @{
                    'Result' = Get-ResourceTitle -Rule $rule
                }
            }

            # Must return a $true value. The skip rules will be included in the mof but no action is taken
            TestScript = {
                return $true
            }

            <#
                This is left blank because we are only using the script resource as an audit tool for
                STIG items that should be part of an orchestration function and not configuration.
            #>
            SetScript = { }
        }
    }
}
