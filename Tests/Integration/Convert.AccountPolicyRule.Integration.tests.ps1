#region Header
. $PSScriptRoot\.tests.header.ps1
#endregion
try
{
    #region Test Setup
    #endregion
    #region Tests
    Describe 'ConvertTo-AccountPolicyRule without range' {
        $checkContent = 'Verify the effective setting in Local Group Policy Editor.
        Run "gpedit.msc".

        Navigate to Local Computer Policy -&gt; Computer Configuration -&gt; Windows Settings -&gt; Security Settings -&gt; Account Policies -&gt; Account Lockout Policy.

        If the value for "Setting to Configure" is not set to "Disabled", this is a finding.'
        [xml] $stigRule = Get-TestStigRule -CheckContent $checkContent -XccdfTitle Windows
        $TestFile = Join-Path -Path $TestDrive -ChildPath 'TextData.xml'
        $stigRule.Save( $TestFile )
        $rule = ConvertFrom-StigXccdf -Path $TestFile

        It 'Should return an AccountPolicyRule Object' {
            $rule.GetType() | Should Be 'AccountPolicyRule'
        }
        It 'Should set the correct Policy Name' {
            $rule.PolicyName | Should Be 'Setting to Configure'
        }
        It 'Should not have OrganizationValueRequired set' {
            $rule.OrganizationValueRequired | Should Be $false
        }
        It 'Should have emtpty test string' {
            $rule.OrganizationValueTestString | Should BeNullOrEmpty
        }
        It "Should set the correct DscResource" {
            $rule.DscResource | Should Be 'AccountPolicy'
        }
        It 'Should Set the status to pass' {
            $rule.conversionstatus | Should Be 'pass'
        }
    }

    Describe 'ConvertTo-AccountPolicyRule with a range' {
        $checkContent = 'Verify the effective setting in Local Group Policy Editor.
        Run "gpedit.msc".

        Navigate to Local Computer Policy -&gt; Computer Configuration -&gt; Windows Settings -&gt; Security Settings -&gt; Account Policies -&gt; Account Lockout Policy.

        If the "Account lockout threshold" is "0" or more than "3" attempts, this is a finding.'
        [xml] $stigRule = Get-TestStigRule -CheckContent $checkContent -XccdfTitle Windows
        $TestFile = Join-Path -Path $TestDrive -ChildPath 'TextData.xml'
        $stigRule.Save( $TestFile )
        $rule = ConvertFrom-StigXccdf -Path $TestFile

        It 'Should set the correct Policy Name' {
            $rule.PolicyName | Should Be 'Account lockout threshold'
        }
        It 'Should set OrganizationValueRequired to true' {
            $rule.OrganizationValueRequired | Should Be $true
        }
        It 'Should have set a test string' {
            $rule.OrganizationValueTestString | Should Be "'{0}' -le '3' -and '{0}' -ne '0'"
        }
        It "Should set the correct DscResource" {
            $rule.DscResource | Should Be 'AccountPolicy'
        }
        It 'Should Set the status to pass' {
            $rule.conversionstatus | Should Be 'pass'
        }
    }
    #endregion
}
finally
{
    . $PSScriptRoot\.tests.footer.ps1
}
