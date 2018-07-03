using module ..\..\..\..\Public\Class\Convert.AccountPolicyRule.psm1
#region Convert Public Class Header V1
. $PSScriptRoot\.Convert.Test.Header.ps1
#endregion
#region Test Setup
$rule = [AccountPolicyRule]::new( (Get-TestStigRule -ReturnGroupOnly) )

$baseString = 'Verify the effective setting in Local Group Policy Editor.
Run "gpedit.msc".

Navigate to Local Computer Policy &gt;&gt; Computer Configuration &gt;&gt; Windows Settings &gt;&gt; Security Settings &gt;&gt; Account Policies &gt;&gt; Account Lockout Policy.

{0}'
#endregion
#region Class Tests
Describe "$($rule.GetType().Name) Child Class" {

    Context 'Base Class' {

        It "Shoud have a BaseType of STIG" {
            $rule.GetType().BaseType.ToString() | Should Be 'STIG'
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

$accountPolicyRulesToTest = @(
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
        PolicyName = 'Store passwords using reversible encryption'
        PolicyValue = 'Disabled'
        CheckContent = 'Verify the effective setting in Local Group Policy Editor.
        Run "gpedit.msc".

        Navigate to Local Computer Policy &gt;&gt; Computer Configuration &gt;&gt; Windows Settings &gt;&gt; Security Settings &gt;&gt; Account Policies &gt;&gt; Password Policy.

        If the value for "Store password using reversible encryption" is not set to "Disabled", this is a finding.'
    }
)

Describe 'Get-AccountPolicyName' {

    foreach ($rule in $accountPolicyRulesToTest)
    {
        It "Should return '$($rule.PolicyName)'" {
            $result = Get-AccountPolicyName -CheckContent ($rule.CheckContent -split '\n')
            $result | Should Be $rule.PolicyName
        }
    }
}

Describe 'Get-AccountPolicyValue' {

    foreach ($rule in $accountPolicyRulesToTest)
    {
        It "Should return '$($rule.PolicyValue)'" {
            $result = Get-AccountPolicyValue -CheckContent ($rule.CheckContent -split '\n')
            $result | Should Be $rule.PolicyValue
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
                $checkContent = ($baseString -f $string) -split '\n'
                Test-SecurityPolicyContainsRange -CheckContent $checkContent| Should Be $true
            }
        }
    }

    Context "Not Match" {

        $strings = @(
            'If the value for "Password must meet complexity requirements" is not set to "Enabled", this is a finding.',
            'If the value for "Store password using reversible encryption" is not set to "Disabled", this is a finding.',
            'If the "Account lockout duration" is not set to "0", requiring an administrator to unlock the account, this is a finding.'
        )

        foreach ($string in $strings)
        {
            It "Should return false from '$string'" {
                $checkContent = ($baseString -f $string) -split '\n'
                Test-SecurityPolicyContainsRange -CheckContent $checkContent | Should Be $false
            }
        }
    }
}
#endregion
