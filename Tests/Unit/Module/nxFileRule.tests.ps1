#region Header
. $PSScriptRoot\.tests.header.ps1
#endregion

try
{
    InModuleScope -ModuleName "$($global:moduleName).Convert" {
        #region Test Setup
        $testRuleList = @(
            @{
                FilePath                  = '/etc/issue'
                Contents                  = 'You are accessing a U.S. Government (USG) Information System (IS) that is provided for USG-authorized use details.'
                OrganizationValueRequired = $false
                CheckContent              = 'Verify the operating system displays the Standard Mandatory DoD Notice and Consent Banner before granting access to the operating system via a command line user logon.

                Check to see if the operating system displays a banner at the command line logon screen with the following command:

                # more /etc/issue

                The command should return the following text:
                "You are accessing a U.S. Government (USG) Information System (IS) that is provided for USG-authorized use details."

                If the operating system does not display a graphical logon banner or the banner does not match the Standard Mandatory DoD Notice and Consent Banner, this is a finding.

                If the text in the "/etc/issue" file does not match the Standard Mandatory DoD Notice and Consent Banner, this is a finding.'
            }
        )
        #endregion

        foreach ($testRule in $testRuleList)
        {
            . $PSScriptRoot\Convert.CommonTests.ps1
        }
    }
}
finally
{
    . $PSScriptRoot\.tests.footer.ps1
}
