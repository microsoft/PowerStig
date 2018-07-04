#region HEADER
. $PSScriptRoot\.Convert.Test.Header.ps1
#endregion
#region Test Setup
$checkContent = 'Verify the effective setting in Local Group Policy Editor.
Run "gpedit.msc".

Navigate to Local Computer Policy -&gt; Computer Configuration -&gt; Windows Settings -&gt; Security Settings -&gt; Local Policies -&gt; Security Options.

If the value for "Network security: Force logoff when logon hours expire" is not set to "Enabled", this is a finding.'
#endregion
#region Tests
try
{
    Describe "ConvertTo-SecurityOptionRule" {

        $stigRule = Get-TestStigRule -CheckContent $checkContent -ReturnGroupOnly
        $rule = ConvertTo-SecurityOptionRule -StigRule $stigRule

        It "Should return a SecurityOptionRule object" {
            $rule.GetType() | Should Be 'SecurityOptionRule'
        }
    }
}
catch
{
    Remove-Variable STIGSettings -Scope Global
}
#endregion
