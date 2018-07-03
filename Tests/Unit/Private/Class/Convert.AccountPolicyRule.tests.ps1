#region HEADER
. $PSScriptRoot\.Convert.Test.Header.ps1
#endregion
#region Test Setup
$checkContent = 'Run "gpedit.msc".

Navigate to Local Computer Policy -&gt; Computer Configuration -&gt; Windows Settings -&gt; Security Settings -&gt; {0} -&gt; Account Lockout Policy.

If the "Account lockout threshold" is "0" or more than "3" attempts, this is a finding.'
#endregion
#region Tests
Describe "ConvertTo-AccountPolicyRule" {

    <#
        This function can't really be unit tested, since the call cannot be mocked by pester, so
        the only thing we can really do at this point is to verify that it returns the correct object.
    #>
    $stigRule = Get-TestStigRule -CheckContent $checkContent -ReturnGroupOnly
    $rule = ConvertTo-AccountPolicyRule -StigRule $stigRule

    It "Should return an AccountPolicyRule object" {
        $rule.GetType() | Should Be 'AccountPolicyRule'
    }
}
#endregion
