#region Header
. $PSScriptRoot\.tests.header.ps1
#endregion

try
{
    $testCases = @(
        @{
            $WebAppUrlandBlockedFileTypesList = $null
            DscResource     = 'SharePointDsc'
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

    Describe 'SPWebAppBlockedFileTypes Conversion' {
        foreach ($testCase in $testCases)
        {
            [xml] $stigRule = Get-TestStigRule -CheckContent $testCase.checkContent -XccdfTitle Windows
            $TestFile = Join-Path -Path $TestDrive -ChildPath 'TextData.xml'
            $stigRule.Save( $TestFile )
            $rule = ConvertFrom-StigXccdf -Path $TestFile

            It 'Should return a SPWebAppBlockedFileTypesRule Object' {
                $rule.GetType() | Should Be 'SPWebAppBlockedFileTypesRule'
            }

            It "Should return Blocked File Types:'$($testCase.BlockedFileTypes)'" {
                $rule.BlockedFileTypes | Should Be $testCase.BlockedFileTypes
            }
            It "Should return Web App Url:'$($testCase.WebAppUrl)'" {
                $rule.WebAppUrl | Should Be $testCase.WebAppUrl
            }
            It "Should set the correct DscResource" {
                $rule.DscResource | Should Be 'SPWebAppBlockedFileTypes'
            }
            It 'Should set the status to pass' {
                $rule.conversionstatus | Should be 'pass'
            }
        }
    }
}
finally
{
    . $PSScriptRoot\.tests.footer.ps1
}
