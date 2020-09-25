#region Header
. $PSScriptRoot\.tests.header.ps1
#endregion

try
{
    InModuleScope -ModuleName "$($global:moduleName).Convert" {
        #region Test Setup
        $testRuleList = @(
            @{
                BlockedFileTypes = $null
                WebAppUrl = $null
                DscResource     = 'SPWebAppBlockedFileTypes'
                OrganizationValueRequired = $true
                OrganizationValueTestString = "'{0}' 'matches the `"blacklist`" document in the application's SSP'"
                CheckContent    = "Review the SharePoint server configuration to ensure non-privileged users are prevented from circumventing malicious code protection capabilities.
    
                Confirm that the list of blocked file types configured in Central Administration matches the `"blacklist`" document in the application's SSP. See TechNet for default file types that are blocked: http://technet.microsoft.com/en-us/library/cc262496.aspx
                
                Navigate to Central Administration.
                
                Click `"Manage web applications`".
                
                Select the web application by clicking its name.
                
                Select `"Blocked File Types`" from the ribbon.
                
                Compare the list of blocked file types to those listed in the SSP. If the SSP has file types that are not in the blocked file types list, this is a finding.
                
                Repeat check for each web application."
                ConversionStatus = 'pass'
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
