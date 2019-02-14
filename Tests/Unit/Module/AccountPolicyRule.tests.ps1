using module .\..\..\..\Module\Rule.AccountPolicy\Convert\AccountPolicyRule.Convert.psm1
#region Header
. $PSScriptRoot\.tests.header.ps1
#endregion
try
{
    InModuleScope -ModuleName "$($script:moduleName).Convert" {
        #region Test Setup
        $rulesToTest = @(
            @{
                PolicyName = 'Account lockout duration'
                PolicyValue = $null
                OrganizationValueRequired = $true
                CheckContent = 'Verify the effective setting in Local Group Policy Editor.
                Run "gpedit.msc".

                Navigate to Local Computer Policy >> Computer Configuration >> Windows Settings >> Security Settings >> Account Policies >> Account Lockout
                Policy.

                If the "Account lockout duration" is less than "15" minutes (excluding "0"), this is a finding.'
            },
            @{
                PolicyName = 'Password must meet complexity requirements'
                PolicyValue = 'Enabled'
                OrganizationValueRequired = $false
                CheckContent = 'Verify the effective setting in Local Group Policy Editor.
                Run "gpedit.msc".

                Navigate to Local Computer Policy >> Computer Configuration >> Windows Settings >> Security Settings >> Account Policies >> Password Policy.

                If the value for "Password must meet complexity requirements" is not set to "Enabled", this is a finding.

                If the site is using a password filter that requires this setting be set to "Disabled" for the filter to be used, this would not be considered a finding.'
            },
            @{
                PolicyName = 'Store passwords using reversible encryption'
                PolicyValue = 'Disabled'
                OrganizationValueRequired = $false
                CheckContent = 'Verify the effective setting in Local Group Policy Editor.
                Run "gpedit.msc".

                Navigate to Local Computer Policy >> Computer Configuration >> Windows Settings >> Security Settings >> Account Policies >> Password Policy.

                If the value for "Store passwords using reversible encryption" is not set to "Disabled", this is a finding.'
            },
            @{
                PolicyName = 'Minimum password length'
                PolicyValue = $null
                OrganizationValueRequired = $true
                CheckContent = 'Verify the effective setting in Local Group Policy Editor.
                Run "gpedit.msc".

                Navigate to Local Computer Policy -> Computer Configuration -> Windows Settings -> Security Settings -> Account Policies -> Password Policy.

                If the value for the "Minimum password length" is less than "14" characters, this is a finding.'
            },
            @{
                PolicyName = 'Enforce user logon restrictions'
                PolicyValue = 'Enabled'
                OrganizationValueRequired = $false
                CheckContent = 'Verify the following is configured in the Default Domain Policy.

                Open "Group Policy Management".
                Navigate to "Group Policy Objects" in the Domain being reviewed (Forest > Domains > Domain).
                Right click on the "Default Domain Policy".
                Select Edit.
                Navigate to Computer Configuration > Policies > Windows Settings > Security Settings > Account Policies > Kerberos Policy.

                If the "Enforce user logon restrictions" is not set to "Enabled", this is a finding.'
            }
        )
        #endregion

        [int]$count = 0
        Foreach ($rule in $rulesToTest)
        {
            $stigRule = Get-TestStigRule -CheckContent $rule.checkContent -ReturnGroupOnly
            $convertedRule = [AccountPolicyRuleConvert]::new( $stigRule )

            If ($count -le 0)
            {
                Describe "$($convertedRule.GetType().Name) Child Class" {
                    Context 'Base Class' {
                        It 'Shoud have a BaseType of AccountPolicyRule' {
                            $convertedRule.GetType().BaseType.ToString() | Should Be 'AccountPolicyRule'
                        }
                    }

                    Context 'Class Properties' {
                        $classProperties = @('PolicyName', 'PolicyValue')
                        foreach ( $property in $classProperties )
                        {
                            It "Should have a property named '$property'" {
                                ( $convertedRule | Get-Member -Name $property ).Name | Should Be $property
                            }
                        }
                    }
                }
                $count ++
            }

            Describe 'Class Instance' {
                It "Should return the Policy Name" {
                    $convertedRule.PolicyName | Should Be $rule.PolicyName
                }
                It "Should return the Policy Value" {
                    $convertedRule.PolicyValue | Should Be $rule.PolicyValue
                }
                It "Should return the Organization Value Required flag" {
                    $convertedRule.OrganizationValueRequired | Should Be $rule.OrganizationValueRequired
                }
            }

            Describe 'Static Match' {
                It 'Should Match the string' {
                    [AccountPolicyRuleConvert]::Match($rule.checkContent) | Should Be $true
                }
            }
        }
    }
}
finally
{
    . $PSScriptRoot\.tests.footer.ps1
}
