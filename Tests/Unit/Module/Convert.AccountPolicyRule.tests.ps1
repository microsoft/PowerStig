using module .\..\..\..\Module\Convert.AccountPolicyRule\Convert.AccountPolicyRule.psm1
#region Header
. $PSScriptRoot\.tests.header.ps1
#endregion
try
{
    InModuleScope -ModuleName $script:moduleName {
        #region Test Setup
        $baseString = 'Verify the effective setting in Local Group Policy Editor.
        Run "gpedit.msc".

        Navigate to Local Computer Policy &gt;&gt; Computer Configuration &gt;&gt; Windows Settings &gt;&gt; Security Settings &gt;&gt; Account Policies &gt;&gt; Account Lockout Policy.

        {0}'
        $rule = [AccountPolicyRule]::new( (Get-TestStigRule -ReturnGroupOnly) )
        #endregion
        #region Class Tests
        Describe "$($rule.GetType().Name) Child Class" {

            Context 'Base Class' {

                It "Shoud have a BaseType of STIG" {
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

            Context 'Class Methods' {

                $classMethods = @('SetPolicyName', 'SetPolicyValue', 'SetPolicyValueRange')

                foreach ( $method in $classMethods )
                {
                    It "Should have a method named '$method'" {
                        ( $rule | Get-Member -Name $method ).Name | Should Be $method
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

        Navigate to Local Computer Policy &gt;&gt; Computer Configuration &gt;&gt; Windows Settings &gt;&gt; Security Settings &gt;&gt; Account Policies &gt;&gt; Account Lockout
        Policy.

        If the "Account lockout duration" is less than "15" minutes (excluding "0"), this is a finding.'
            }
            @{
                PolicyName   = 'Password must meet complexity requirements'
                PolicyValue  = 'Enabled'
                CheckContent = 'Verify the effective setting in Local Group Policy Editor.
        Run "gpedit.msc".

        Navigate to Local Computer Policy &gt;&gt; Computer Configuration &gt;&gt; Windows Settings &gt;&gt; Security Settings &gt;&gt; Account Policies &gt;&gt; Password Policy.

        If the value for "Password must meet complexity requirements" is not set to "Enabled", this is a finding.

        If the site is using a password filter that requires this setting be set to "Disabled" for the filter to be used, this would not be considered a finding.'
            }
            @{
                PolicyName   = 'Store passwords using reversible encryption'
                PolicyValue  = 'Disabled'
                CheckContent = 'Verify the effective setting in Local Group Policy Editor.
        Run "gpedit.msc".

        Navigate to Local Computer Policy &gt;&gt; Computer Configuration &gt;&gt; Windows Settings &gt;&gt; Security Settings &gt;&gt; Account Policies &gt;&gt; Password Policy.

        If the value for "Store password using reversible encryption" is not set to "Disabled", this is a finding.'
            }
        )

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

                $strings = @(
                    'If the "Reset account lockout counter after" value is less than "15" minutes, this is a finding.',
                    'If the value for "Enforce password history" is less than "24" passwords remembered, this is a finding.',
                    'If the "Account lockout threshold" is "0" or more than "3" attempts, this is a finding.',
                    'If the "Account lockout duration" is less than "15" minutes (excluding "0"), this is a finding.',
                    'If the value for the "Minimum password length," is less than "14" characters, this is a finding.',
                    'If the value for the "Minimum password age" is set to "0" days ("Password can be changed immediately."), this is a finding.',
                    'If the value for the "Maximum password age" is greater than "60" days, this is a finding.  If the value is set to "0" (never expires), this is a finding.'
                )

                foreach ($string in $strings)
                {
                    It "Should return true from '$string'" {
                        $checkContent = Split-TestStrings -CheckContent ($baseString -f $string)
                        Test-SecurityPolicyContainsRange -CheckContent $checkContent| Should Be $true
                    }
                }
            }

            Context 'Not Match' {

                $strings = @(
                    'If the value for "Password must meet complexity requirements" is not set to "Enabled", this is a finding.',
                    'If the value for "Store password using reversible encryption" is not set to "Disabled", this is a finding.',
                    'If the "Account lockout duration" is not set to "0", requiring an administrator to unlock the account, this is a finding.'
                )

                foreach ($string in $strings)
                {
                    It "Should return false from '$string'" {
                        $checkContent = Split-TestStrings -CheckContent ($baseString -f $string)
                        Test-SecurityPolicyContainsRange -CheckContent $checkContent | Should Be $false
                    }
                }
            }
        }
        #endregion
        #region Function Tests
        $checkContent = 'Run "gpedit.msc".

Navigate to Local Computer Policy -&gt; Computer Configuration -&gt; Windows Settings -&gt; Security Settings -&gt; {0} -&gt; Account Lockout Policy.

If the "Account lockout threshold" is "0" or more than "3" attempts, this is a finding.'
        Describe 'ConvertTo-AccountPolicyRule' {
            <#
            This function can't really be unit tested, since the call cannot be mocked by pester, so
            the only thing we can really do at this point is to verify that it returns the correct object.
        #>
            $stigRule = Get-TestStigRule -CheckContent $checkContent -ReturnGroupOnly
            $rule = ConvertTo-AccountPolicyRule -StigRule $stigRule

            It 'Should return an AccountPolicyRule object' {
                $rule.GetType() | Should Be 'AccountPolicyRule'
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
