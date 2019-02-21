#region Header
using module .\..\..\..\Module\Rule.MimeType\Convert\MimeTypeRule.Convert.psm1
. $PSScriptRoot\.tests.header.ps1
#endregion

try
{
    InModuleScope -ModuleName "$($global:moduleName).Convert" {
        #region Test Setup
        $testRuleList = @(
            @{
                Ensure = 'absent'
                MimeType = 'application/octet-stream'
                Extension = '.exe'
                OrganizationValueRequired = $false
                CheckContent = 'Follow the procedures below for each site hosted on the IIS 8.5 web server:

                    Open the IIS 8.5 Manager.

                    Click on the IIS 8.5 site.

                    Under IIS, double-click the MIME Types icon.

                    From the "Group by:" drop-down list, select "Content Type".

                    From the list of extensions under "Application", verify MIME types for OS shell program extensions have been removed, to include at a minimum, the following extensions:

                    .exe

                    If any OS shell MIME types are configured, this is a finding.'
            }
        )
        #endregion

        Foreach ($testRule in $testRuleList)
        {
            . $PSScriptRoot\Convert.CommonTests.ps1
        }

        #region Add Custom Tests Here
        Describe 'MultipleRules' {
            # TODO move this to the CommonTests
            $testRuleList = @(
                @{
                    Count = 5
                    CheckContent = 'Follow the procedures below for each site hosted on the IIS 8.5 web server:

                    Open the IIS 8.5 Manager.

                    Click on the IIS 8.5 site.

                    Under IIS, double-click the MIME Types icon.

                    From the "Group by:" drop-down list, select "Content Type".

                    From the list of extensions under "Application", verify MIME types for OS shell program extensions have been removed, to include at a minimum, the following extensions:

                    .exe
                    .dll
                    .com
                    .bat
                    .csh

                    If any OS shell MIME types are configured, this is a finding.'
                }
            )
            foreach($testRule in $testRuleList)
            {
                It "Should return $true" {
                    $multipleRule = [MimeTypeRuleConvert]::HasMultipleRules($testRule.CheckContent)
                    $multipleRule | Should -Be $true
                }
                It "Should return $($testRule.Count) rules" {
                    $multipleRule = [MimeTypeRuleConvert]::SplitMultipleRules($testRule.CheckContent)
                    $multipleRule.count | Should -Be $testRule.Count
                }
            }
        }
        #endregion
    }
}
finally
{
    . $PSScriptRoot\.tests.footer.ps1
}
