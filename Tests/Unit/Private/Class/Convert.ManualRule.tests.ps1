#region HEADER
. $PSScriptRoot\.Convert.Test.Header.ps1
#endregion
#region Test Setup
$checkContent = 'Verify servers are located in controlled access areas that are accessible only to authorized personnel.  If systems are not adequately protected, this is a finding.'
#endregion
#region Tests
try
{
    Describe "ConvertTo-ManualRule" {
        <#
            This function can't really be unit tested, since the call cannot be mocked by pester, so
            the only thing we can really do at this point is to verify that it returns the correct object.
        #>
        $stigRule = Get-TestStigRule -CheckContent $checkContent -ReturnGroupOnly
        $rule = ConvertTo-ManualRule -StigRule $stigRule

        It "Should return an ManualRule object" {
            $rule.GetType() | Should Be 'ManualRule'
        }
    }
}
catch
{
    Remove-Variable STIGSettings -Scope Global
}
#endregion
