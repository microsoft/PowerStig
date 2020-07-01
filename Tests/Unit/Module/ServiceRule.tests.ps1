#region Header
. $PSScriptRoot\.tests.header.ps1
#endregion

try
{
    InModuleScope -ModuleName "$($global:moduleName).Convert" {
        #region Test Setup
        $testRuleList = @(
            @{
                ServiceName = 'masvc'
                ServiceState = 'Running'
                StartupType = 'Automatic'
                Ensure = 'Present'
                OrganizationValueRequired = $false
                CheckContent = 'Run "Services.msc".

                Verify the McAfee Agent service is running, depending on the version installed.

                Version - Service Name
                McAfee Agent v5.x - McAfee Agent Service
                McAfee Agent v4.x - McAfee Framework Service

                If the service is not listed or does not have a Status of "Started", this is a finding.'
            },
            @{
                ServiceName = 'SCPolicySvc'
                ServiceState = 'Running'
                StartupType = 'Automatic'
                Ensure = 'Present'
                OrganizationValueRequired = $false
                CheckContent = 'Verify the Smart Card Removal Policy service is configured to "Automatic".

                Run "Services.msc".

                If the Startup Type for Smart Card Removal Policy is not set to Automatic, this is a finding.'
            },
            @{
                ServiceName = 'simptcp'
                ServiceState = 'Stopped'
                StartupType = 'Disabled'
                Ensure = 'Present'
                OrganizationValueRequired = $false
                CheckContent = 'Verify the Simple TCP/IP (simptcp) service is not installed or is disabled.

                Run "Services.msc".

                If the following is installed and not disabled, this is a finding:

                Simple TCP/IP Services (simptcp)'
            },
            @{
                ServiceName = 'FTPSVC'
                ServiceState = 'Stopped'
                StartupType = 'Disabled'
                Ensure = 'Present'
                OrganizationValueRequired = $false
                CheckContent = 'If the server has the role of an FTP server, this is NA.
                Run "Services.msc".

                If the "Microsoft FTP Service" (Service name: FTPSVC) is installed and not disabled, this is a finding.'
            },
            @{
                ServiceName = $null
                ServiceState = 'Stopped'
                StartupType = 'Disabled'
                Ensure = 'Present'
                OrganizationValueRequired = $false
                CheckContent = 'If the server has the role of a server, this is NA.
                Run "Services.msc".

                If A string without parentheses is installed and not disabled, this is a finding.'
            }
        )
        #endregion

        foreach ($testRule in $testRuleList)
        {
            . $PSScriptRoot\Convert.CommonTests.ps1
        }

        #region Add Custom Tests Here
        Describe 'MultipleRules' {
            # TODO move this to the CommonTests
            $testRuleList = @(
                @{
                    Count = 9
                    CheckContent = 'Run "services.msc" to display the Services console.

                    Verify the Startup Type for the following Windows services:
                    - Active Directory Domain Services
                    - DFS Replication
                    - DNS Client
                    - DNS server
                    - Group Policy Client
                    - Intersite Messaging
                    - Kerberos Key Distribution Center
                    - NetLogon
                    - Windows Time (not required if another time synchronization tool is implemented to start automatically)

                    If the Startup Type for any of these services is not Automatic, this is a finding.'
                }
            )

            foreach ($testRule in $testRuleList)
            {
                # Get the rule element with the checkContent injected into it
                $stigRule = Get-TestStigRule -CheckContent $testRule.CheckContent -ReturnGroupOnly
                # Create an instance of the convert class that is currently being tested
                $convertedRule = [ServiceRuleConvert]::new($stigRule)
                It "Should return $true" {
                    $convertedRule.HasMultipleRules() | Should Be $true
                }
                It "Should return $($testRule.Count) rules" {
                    $multipleRule = $convertedRule.SplitMultipleRules()
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
