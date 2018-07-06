#region HEADER
. $PSScriptRoot\.Convert.Test.Header.ps1
#endregion
#region Test Setup
$checkContent = 'Security Option "Audit: Force audit policy subcategory settings (Windows Vista or later) to override audit policy category settings" must be set to "Enabled" (V-14230) for the detailed auditing subcategories to be effective.

Use the AuditPol tool to review the current Audit Policy configuration:
-Open a Command Prompt with elevated privileges ("Run as Administrator").
-Enter "AuditPol /get /category:*".

Compare the AuditPol settings with the following.  If the system does not audit the following, this is a finding.

Account Management -&gt; Computer Account Management - Success'
#endregion
#region Tests
try
{
    Describe "ConvertTo-AuditPolicyRule" {

        <#
            This function can't really be unit tested, since the call cannot be mocked by pester, so
            the only thing we can really do at this point is to verify that it returns the correct object.
        #>
        $stigRule = Get-TestStigRule -CheckContent $checkContent -ReturnGroupOnly
        $rule = ConvertTo-AuditPolicyRule -StigRule $stigRule

        It "Should return an AuditPolicyRule object" {
            $rule.GetType() | Should Be 'AuditPolicyRule'
        }
    }
}
catch
{
    Remove-Variable STIGSettings -Scope Global
}
#endregion
