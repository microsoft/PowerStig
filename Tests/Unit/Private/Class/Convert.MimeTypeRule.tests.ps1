#region HEADER
. $PSScriptRoot\.Convert.Test.Header.ps1
#endregion
#region Test Setup
$checkContent = 'Follow the procedures below for each site hosted on the IIS 8.5 web server:

Open the IIS 8.5 Manager.

Click on the IIS 8.5 site.

Under IIS, double-click the MIME Types icon.

From the "Group by:" drop-down list, select "Content Type".

From the list of extensions under "Application", verify MIME types for OS shell program extensions have been removed, to include at a minimum, the following extensions:

.exe

If any OS shell MIME types are configured, this is a finding.'
#endregion
#region Tests
try
{
    Describe "ConvertTo-MimeTypeRule" {
        $stigRule = Get-TestStigRule -CheckContent $checkContent -ReturnGroupOnly
        $rule = ConvertTo-MimeTypeRule -StigRule $stigRule

        It "Should return an MimeTypeRule object" {
            $rule.GetType() | Should Be 'MimeTypeRule'
        }
    }
}
catch
{
    Remove-Variable STIGSettings -Scope Global
}
#endregion Function Tests
