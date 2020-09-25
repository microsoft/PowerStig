#region Header
. $PSScriptRoot\.tests.header.ps1
#endregion

try
{
    $testCases = @(
        @{
            SPLogLevelItems = $null
            DscResource     = 'SPLogLevel'
            CheckContent    = "Review the SharePoint server configuration to ensure designated organizational personnel are allowed to select which auditable events are to be audited by specific components of the system.

            Navigate to Central Administration.
            
            Click `"Monitoring`".
            
            Click `"Configure Diagnostic Logging`".
            
            Validate that the selected event categories and trace levels match those defined by the organization's system security plan.
            
            Remember that a base set of events are always audited.
            
            If the selected event categories/trace levels are inconsistent with those defined in the organization's system security plan, this is a finding."
            ConversionStatus = 'pass'
        }
    )

    Describe 'SPLogLevel Conversion' {
        foreach ($testCase in $testCases)
        {
            [xml] $stigRule = Get-TestStigRule -CheckContent $testCase.checkContent -XccdfTitle Windows
            $TestFile = Join-Path -Path $TestDrive -ChildPath 'TextData.xml'
            $stigRule.Save( $TestFile )
            $rule = ConvertFrom-StigXccdf -Path $TestFile

            It 'Should return a SPLogLevelRule Object' {
                $rule.GetType() | Should Be 'SPLogLevelRule'
            }
            It "Should return hash Log Level Items:'$($testCase.SPLogLevelItems)'" {
                $rule.SPLogLevelItems | Should Be $testCase.SPLogLevelItems
            }
            It "Should set the correct DscResource" {
                $rule.DscResource | Should Be 'SPLogLevel'
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
