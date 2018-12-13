using module .\..\..\..\Module\AccountPolicyRule\AccountPolicyRule.psm1
#region Header
. $PSScriptRoot\.tests.header.ps1
#endregion
try
{
    InModuleScope -ModuleName $script:moduleName {
        #region Test Setup
        $checkContentBase = 'Verify the effective setting in Local Group Policy Editor.
        Run "gpedit.msc".

        Navigate to Local Computer Policy >> Computer Configuration >> Windows Settings >> Security Settings >> Account Policies >> Account Lockout Policy.

        {0}'

        $checkContentString = 'If the "Reset account lockout counter after" value is less than "15" minutes, this is a finding.'
        $stigRule = Get-TestStigRule -CheckContent ($checkContentBase -f $checkContentString) -ReturnGroupOnly
        $rule = [AccountPolicyRule]::new( $stigRule )
        #endregion
        #region Class Tests

        Describe "$($rule.GetType().Name) Child Class" {

            Context 'Base Class' {

                It 'Shoud have a BaseType of STIG' {
                    $rule.GetType().BaseType.ToString() | Should Be 'Rule'
                }
            }

            Context 'Class Properties' {

                $classProperties = @('PolicyName', 'PolicyValue')

                foreach ( $property in $classProperties )
                {
                    It "Should have a property named '$property'" {
                        ( $rule | Get-Member -Name $property ).Name | Should Be $property
                    }
                }
            }
        }
        #endregion
        #region Method Tests
        $rulesToTest = @(
            @{
                PolicyName   = 'Account lockout duration'
                PolicyValue  = '15'
                CheckContent = 'Verify the effective setting in Local Group Policy Editor.
                Run "gpedit.msc".

                Navigate to Local Computer Policy >> Computer Configuration >> Windows Settings >> Security Settings >> Account Policies >> Account Lockout
                Policy.

                If the "Account lockout duration" is less than "15" minutes (excluding "0"), this is a finding.'
            },
            @{
                PolicyName   = 'Password must meet complexity requirements'
                PolicyValue  = 'Enabled'
                CheckContent = 'Verify the effective setting in Local Group Policy Editor.
                Run "gpedit.msc".

                Navigate to Local Computer Policy >> Computer Configuration >> Windows Settings >> Security Settings >> Account Policies >> Password Policy.

                If the value for "Password must meet complexity requirements" is not set to "Enabled", this is a finding.

                If the site is using a password filter that requires this setting be set to "Disabled" for the filter to be used, this would not be considered a finding.'
            },
            @{
                PolicyName   = 'Store passwords using reversible encryption'
                PolicyValue  = 'Disabled'
                CheckContent = 'Verify the effective setting in Local Group Policy Editor.
                Run "gpedit.msc".

                Navigate to Local Computer Policy >> Computer Configuration >> Windows Settings >> Security Settings >> Account Policies >> Password Policy.

                If the value for "Store password using reversible encryption" is not set to "Disabled", this is a finding.'
            },
            @{
                PolicyName   = 'Minimum password length'
                PolicyValue  = '14'
                CheckContent = 'Verify the effective setting in Local Group Policy Editor.
                Run "gpedit.msc".

                Navigate to Local Computer Policy -> Computer Configuration -> Windows Settings -> Security Settings -> Account Policies -> Password Policy.

                If the value for the "Minimum password length," is less than "14" characters, this is a finding.'
            },
            @{
                PolicyName   = 'Enforce user logon restrictions'
                PolicyValue  = 'Enabled'
                CheckContent = 'Verify the following is configured in the Default Domain Policy.

                Open "Group Policy Management".
                Navigate to "Group Policy Objects" in the Domain being reviewed (Forest > Domains > Domain).
                Right click on the "Default Domain Policy".
                Select Edit.
                Navigate to Computer Configuration > Policies > Windows Settings > Security Settings > Account Policies > Kerberos Policy.

                If the "Enforce user logon restrictions" is not set to "Enabled", this is a finding.'
            }
        )

        Describe 'Static Match' {

            Foreach($rule in $rulesToTest)
            {
                It 'Should Match the string' {
                    [AccountPolicyRule]::Match($rule.checkContent) | Should Be $true
                }
            }
        }

        Describe 'Get-AccountPolicyName' {

            foreach ($rule in $rulesToTest)
            {
                It "Should return '$($rule.PolicyName)'" {
                    $checkContent = Split-TestStrings -CheckContent $rule.CheckContent
                    Get-AccountPolicyName -CheckContent $checkContent | Should Be $rule.PolicyName
                }
            }
        }

        Describe 'Get-AccountPolicyValue' {

            foreach ($rule in $rulesToTest)
            {
                It "Should return '$($rule.PolicyValue)'" {
                    $checkContent = Split-TestStrings -CheckContent $rule.CheckContent
                    Get-AccountPolicyValue -CheckContent $checkContent | Should Be $rule.PolicyValue
                }
            }
        }

        Describe 'Test-SecurityPolicyContainsRange' {

            Context 'Match' {

                $checkContentStrings = @(
                    'If the "Reset account lockout counter after" value is less than "15" minutes, this is a finding.',
                    'If the value for "Enforce password history" is less than "24" passwords remembered, this is a finding.',
                    'If the "Account lockout threshold" is "0" or more than "3" attempts, this is a finding.',
                    'If the "Account lockout duration" is less than "15" minutes (excluding "0"), this is a finding.',
                    'If the value for the "Minimum password length," is less than "14" characters, this is a finding.',
                    'If the value for the "Minimum password age" is set to "0" days ("Password can be changed immediately."), this is a finding.',
                    'If the value for the "Maximum password age" is greater than "60" days, this is a finding.  If the value is set to "0" (never expires), this is a finding.',
                    'If the value for "Maximum lifetime for user ticket" is 0 or greater than 10 hours, this is a finding.',
                    'If the "Maximum lifetime for user ticket renewal" is greater than 7 days, this is a finding.'
                )

                foreach ($checkContentString in $checkContentStrings)
                {
                    It "Should return true from '$checkContentString'" {
                        $checkContent = Split-TestStrings -CheckContent ($checkContentBase -f $checkContentString)
                        Test-SecurityPolicyContainsRange -CheckContent $checkContent| Should Be $true
                    }
                }
            }

            Context 'Not Match' {

                $checkContentStrings = @(
                    'If the value for "Password must meet complexity requirements" is not set to "Enabled", this is a finding.',
                    'If the value for "Store password using reversible encryption" is not set to "Disabled", this is a finding.',
                    'If the "Account lockout duration" is not set to "0", requiring an administrator to unlock the account, this is a finding.'
                )

                foreach ($checkContentString in $checkContentStrings)
                {
                    It "Should return false from '$checkContentString'" {
                        $checkContent = Split-TestStrings -CheckContent ($checkContentBase -f $checkContentString)
                        Test-SecurityPolicyContainsRange -CheckContent $checkContent | Should Be $false
                    }
                }
            }
        }
        #endregion
        #region Data Tests
        Describe 'PolicyNameFixes Data Section' {

            [string] $dataSectionName = 'PolicyNameFixes'

            It "Should have a data section called $dataSectionName" {
                ( Get-Variable -Name $dataSectionName ).Name | Should Be $dataSectionName
            }
        }
        #endregion
    }
}
finally
{
    . $PSScriptRoot\.tests.footer.ps1
}
