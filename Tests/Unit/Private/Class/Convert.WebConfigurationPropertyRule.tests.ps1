#region HEADER
. $PSScriptRoot\.Convert.Test.Header.ps1
#endregion
#region Test Setup
$checkContent = 'Follow the procedures below for each site hosted on the IIS 8.5 web server:

Open the IIS 8.5 Manager.

Click the site name.

Under the "ASP.NET" section, select "Session State".

Under "Cookie Settings", verify the "Use URI" mode is selected from the "Mode:" drop-down list.

If the "Use URI" mode is selected, this is not a finding.

Alternative method:

Click the site name.

Select "Configuration Editor" under the "Management" section.

From the "Section:" drop-down list at the top of the configuration editor, locate "system.web/sessionState".

Verify the "cookieless" is set to "UseURI".

If the "cookieless" is not set to "UseURI", this is a finding.'
#endregion
#region Tests
Describe "ConvertTo-WebConfigurationPropertyRule" {
    $stigRule = Get-TestStigRule -CheckContent $checkContent -ReturnGroupOnly
    $rule = ConvertTo-WebConfigurationPropertyRule -StigRule $stigRule

    It "Should return an WebConfigurationPropertyRule object" {
        $rule.GetType() | Should Be 'WebConfigurationPropertyRule'
    }
}
#endregion
