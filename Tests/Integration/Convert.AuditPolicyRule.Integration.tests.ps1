#region Header
. $PSScriptRoot\.tests.header.ps1
#endregion

try
{
    #region Test Setup
    $checkContent = 'Security Option "Audit: Force audit policy subcategory settings (Windows Vista or later) to override audit policy category settings" must be set to "Enabled" (V-14230) for the detailed auditing subcategories to be effective. 

Use the AuditPol tool to review the current Audit Policy configuration:
-Open a Command Prompt with elevated privileges ("Run as Administrator").
-Enter "AuditPol /get /category:*".

Compare the AuditPol settings with the following.  If the system does not audit the following, this is a finding.

Account Management -&gt; Computer Account Management - Success'
    #endregion
    #region Tests
    Describe "Audit Policy Conversion" {
        [xml] $StigRule = Get-TestStigRule -CheckContent $checkContent -XccdfTitle Windows
        $TestFile = Join-Path -Path $TestDrive -ChildPath 'TextData.xml'
        $StigRule.Save( $TestFile )
        $rule = ConvertFrom-StigXccdf -Path $TestFile

        It "Should return an AuditPolicyRule Object" {
            $rule.GetType() | Should Be 'AuditPolicyRule'
        }
        It "Should extract the correct SubCategory" {
            $rule.SubCategory | Should Be 'Computer Account Management'
        }
        It "Should extract the correct AuditFlag" {
            $rule.AuditFlag | Should be 'Success'
        }
        It "Should set the correct ensure value" {
            $rule.Ensure | Should be 'Present'
        }
        It "Should set the Conversion statud to pass ensure value" {
            $rule.conversionstatus | Should be 'pass'
        }
    }
    #endregion
}
finally
{
    . $PSScriptRoot\.tests.footer.ps1
}
