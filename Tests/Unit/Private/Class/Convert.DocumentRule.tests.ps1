#region HEADER
. $PSScriptRoot\.Convert.Test.Header.ps1
#endregion
#region Test Setup
$checkContent = 'If no accounts are members of the Backup Operators group, this is NA.

Any accounts that are members of the Backup Operators group, including application accounts, must be documented with the ISSO.  If documentation of accounts that are members of the Backup Operators group is not maintained this is a finding.'
#endregion
#region Tests
Describe "ConvertTo-DocumentRule" {

    <#
        This function can't really be unit tested, since the call cannot be mocked by pester, so
        the only thing we can really do at this point is to verify that it returns the correct object.
    #>
    $stigRule = Get-TestStigRule -CheckContent $checkContent -ReturnGroupOnly
    $rule = ConvertTo-DocumentRule -StigRule $stigRule

    It "Should return an DocumentRule object" {
        $rule.GetType() | Should Be 'DocumentRule'
    }
}
#endregion
