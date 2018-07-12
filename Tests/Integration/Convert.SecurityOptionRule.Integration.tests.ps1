#region Header
. $PSScriptRoot\.tests.header.ps1
#endregion
try
{
    #region Test Setup
    $testStrings = @(
        @{
            OptionName = 'Network security: Force logoff when logon hours expire'
            OptionValue = 'Enabled'
            OrganizationValueRequired = $false
            CheckContent = 'Verify the effective setting in Local Group Policy Editor.
            Run "gpedit.msc".
            
            Navigate to Local Computer Policy -&gt; Computer Configuration -&gt; Windows Settings -&gt; Security Settings -&gt; Local Policies -&gt; Security Options.
            
            If the value for "Network security: Force logoff when logon hours expire" is not set to "Enabled", this is a finding.'
        },
        @{
            OptionName = 'Accounts: Rename administrator account'
            OptionValue = $null
            OrganizationValueRequired = $true
            OrganizationValueTestString = "'{0}' -ne 'Administrator'"
            CheckContent = 'Verify the effective setting in Local Group Policy Editor.
            Run "gpedit.msc".
            
            Navigate to Local Computer Policy -&gt; Computer Configuration -&gt; Windows Settings -&gt; Security Settings -&gt; Local Policies -&gt; Security Options.
            
            If the value for "Accounts: Rename administrator account" is not set to a value other than "Administrator", this is a finding.'
        }
    )
    #endregion
    #region Tests
    Describe "Security Option Conversion" {

        foreach ( $testString in $testStrings )
        {
            [xml] $StigRule = Get-TestStigRule -CheckContent $testString.CheckContent -XccdfTitle Windows
            $TestFile = Join-Path -Path $TestDrive -ChildPath 'TextData.xml'
            $StigRule.Save( $TestFile )
            $rule = ConvertFrom-StigXccdf -Path $TestFile
            
            It "Should return an SecurityOptionRule Object" {
                $rule.GetType() | Should Be 'SecurityOptionRule'
            }
            It "Should set Option Name to '$($testString.OptionName)'" {
                $rule.OptionName | Should Be $testString.OptionName
            }
            It "Should set Option Value to '$($testString.OptionValue)'" {
                $rule.OptionValue | Should Be $testString.OptionValue
            }
            It "Should set OrganizationValueRequired to $($testString.OrganizationValueRequired)" {
                $rule.OrganizationValueRequired | Should Be $testString.OrganizationValueRequired
            }
            It "Should set OrganizationValueTestString to $($testString.OrganizationValueTestString)" {
                $rule.OrganizationValueTestString | Should Be $testString.OrganizationValueTestString
            }
            It 'Should Set the status to pass' {
                $rule.conversionstatus | Should Be 'pass'
            }
        }
    }
    #endregion
}
finally
{
    . $PSScriptRoot\.tests.footer.ps1
}
