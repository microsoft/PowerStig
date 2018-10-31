#region Header
using module .\..\..\..\Module\ServiceRule\ServiceRule.psm1
. $PSScriptRoot\.tests.header.ps1
#endregion
try
{
    InModuleScope -ModuleName $script:moduleName {
        #region Test Setup
        $rulesToTest = @(
            @{
                ServiceName = 'masvc'
                ServiceState = 'Running'
                StartupType = 'Automatic'
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
                CheckContent = 'Verify the Smart Card Removal Policy service is configured to "Automatic".

                Run "Services.msc".

                If the Startup Type for Smart Card Removal Policy is not set to Automatic, this is a finding.'
            },
            @{
                ServiceName = 'simptcp'
                ServiceState = 'Stopped'
                StartupType = 'Disabled'
                CheckContent = 'Verify the Simple TCP/IP (simptcp) service is not installed or is disabled.

                Run "Services.msc".

                If the following is installed and not disabled, this is a finding:

                Simple TCP/IP Services (simptcp)'
            },
            @{
                ServiceName = 'FTPSVC'
                ServiceState = 'Stopped'
                StartupType = 'Disabled'
                CheckContent = 'If the server has the role of an FTP server, this is NA.
                Run "Services.msc".

                If the "Microsoft FTP Service" (Service name: FTPSVC) is installed and not disabled, this is a finding.'
            },
            @{
                ServiceName = $null
                ServiceState = 'Stopped'
                StartupType = 'Disabled'
                CheckContent = 'If the server has the role of a server, this is NA.
                Run "Services.msc".

                If A string without parentheses is installed and not disabled, this is a finding.'
            }
        )

        $stigRule = Get-TestStigRule -CheckContent $rulesToTest[0].CheckContent -ReturnGroupOnly
        $rule = [ServiceRule]::new( $stigRule )
        #endregion
        #region Class Tests
        Describe "$($rule.GetType().Name) Child Class" {

            Context 'Base Class' {

                It 'Shoud have a BaseType of STIG' {
                    $rule.GetType().BaseType.ToString() | Should Be 'Rule'
                }
            }

            Context 'Class Properties' {

                $classProperties = @('ServiceName', 'ServiceState', 'StartupType', 'Ensure')

                foreach ( $property in $classProperties )
                {
                    It "Should have a property named '$property'" {
                        ( $rule | Get-Member -Name $property ).Name | Should Be $property
                    }
                }
            }
        }
        #endregion
        #region Method Tests
        Describe 'Get-ServiceName' {

            foreach ( $service in $rulesToTest )
            {
                It "Should return '$($service.ServiceName)'" {
                    $checkContent = Split-TestStrings -CheckContent $service.CheckContent
                    Get-ServiceName -CheckContent $checkContent | Should Be $service.ServiceName
                }
            }
        }

        Describe 'Get-ServiceState' {

            foreach ( $service in $rulesToTest )
            {
                It "Should return '$($service.ServiceState)' from '$($service.ServiceName)'" {
                    $checkContent = Split-TestStrings -CheckContent $service.CheckContent
                    Get-ServiceState -CheckContent $checkContent | Should Be $service.ServiceState
                }
            }
        }

        Describe 'Get-ServiceStartupType' {

            foreach ( $service in $rulesToTest )
            {
                It "Should return '$($service.StartupType)' from '$($service.ServiceName)'" {
                    $checkContent = Split-TestStrings -CheckContent $service.CheckContent
                    Get-ServiceStartupType -CheckContent $checkContent | Should Be $service.StartupType
                }
            }
        }

        Describe 'Test-MultipleServiceRule' {

            It "Should return $true if Multiple Services are found " {
                Test-MultipleServiceRule -ServiceName "NTDS,DFSR,DNS,W32Time" | Should Be $true
            }
            It "Should return $false if a comma is found" {
                Test-MultipleServiceRule -ServiceName "service" | Should Be $false
            }
            It "Should return $false if a null value is passed" {
                Test-MultipleServiceRule -ServiceName $null | Should Be $false
            }
            It 'Should not thrown an error if a null value is passed' {
                {Test-MultipleServiceRule -ServiceName $null} | Should Not Throw
            }
        }
        #endregion
        #region Data Tests
        Describe 'ServicesDisplayNameToName Data Section' {

            [string] $dataSectionName = 'ServicesDisplayNameToName'

            It "Should have a data section called $dataSectionName" {
                ( Get-Variable -Name $dataSectionName ).Name | Should Be $dataSectionName
            }

            <#
            TO DO - Add rules
            #>
        }
        #endregion
    }
}
finally
{
    . $PSScriptRoot\.tests.footer.ps1
}
