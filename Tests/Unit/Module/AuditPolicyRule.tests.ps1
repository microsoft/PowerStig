#region Header
using module .\..\..\..\Module\Rule.AuditPolicy\Convert\AuditPolicyRule.Convert.psm1
. $PSScriptRoot\.tests.header.ps1
#endregion

try
{
    InModuleScope -ModuleName "$($global:moduleName).Convert" {
        #region Test Setup
        $testRuleList = @(
            @{
                Subcategory = 'Computer Account Management'
                AuditFlag = 'Success'
                Ensure = 'Present'
                OrganizationValueRequired = $false
                OrganizationValueTestString = $null
                CheckContent = 'Security Option "Audit: Force audit policy subcategory settings (Windows Vista or later) to override audit policy category settings" must be set to "Enabled" (V-14230) for the detailed auditing subcategories to be effective.

                Use the AuditPol tool to review the current Audit Policy configuration:
                -Open a Command Prompt with elevated privileges ("Run as Administrator").
                -Enter "AuditPol /get /category:*".

                Compare the AuditPol settings with the following.
                If the system does not audit the following, this is a finding.

                Account Management -&gt; Computer Account Management - Success'
            },
            @{
                Subcategory = 'Account Lockout'
                AuditFlag = 'Success'
                Ensure = 'Present'
                OrganizationValueRequired = $false
                OrganizationValueTestString = $null
                CheckContent = 'Security Option "Audit: Force audit policy subcategory settings (Windows Vista or later) to override audit policy category settings" must be set to "Enabled" (V-14230) for the detailed auditing subcategories to be effective.

                Use the AuditPol tool to review the current Audit Policy configuration:
                -Open a Command Prompt with elevated privileges ("Run as Administrator").
                -Enter "AuditPol /get /category:*".

                Compare the AuditPol settings with the following.
                If the system does not audit the following, this is a finding.

                Logon/Logoff &gt;&gt; Account Lockout - Success'
            }
        )
        #endregion

        foreach ($testRule in $testRuleList)
        {
            . $PSScriptRoot\Convert.CommonTests.ps1
        }

        #region Add Custom Tests Here

        #endregion
    }
}
finally
{
    . $PSScriptRoot\.tests.footer.ps1
}
