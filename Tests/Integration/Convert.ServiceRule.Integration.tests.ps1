#region Header
. $PSScriptRoot\.tests.header.ps1
#endregion
try
{
    #region Test Setup
    $servicesToTest = @(
        @{
            ServiceName  = 'masvc'
            ServiceState = 'Running'
            StartupType  = 'Automatic'
            CheckContent = 'Run "Services.msc".
        
            Verify the McAfee Agent service is running, depending on the version installed.
        
            Version - Service Name
            McAfee Agent v5.x - McAfee Agent Service
            McAfee Agent v4.x - McAfee Framework Service
        
            If the service is not listed or does not have a Status of "Started", this is a finding.'
            ConversionStatus = 'pass'
        },
        @{
            ServiceName  = 'SCPolicySvc'
            ServiceState = 'Running'
            StartupType  = 'Automatic'
            CheckContent = 'Verify the Smart Card Removal Policy service is configured to "Automatic".
        
            Run "Services.msc".
        
            If the Startup Type for Smart Card Removal Policy is not set to Automatic, this is a finding.'
            ConversionStatus = 'pass'
        },
        @{
            ServiceName  = 'simptcp'
            ServiceState = 'Stopped'
            StartupType  = 'Disabled'
            CheckContent = 'Verify the Simple TCP/IP (simptcp) service is not installed or is disabled.
        
            Run "Services.msc".
        
            If the following is installed and not disabled, this is a finding:
        
            Simple TCP/IP Services (simptcp)'
            ConversionStatus = 'pass'
        },
        @{
            ServiceName  = 'FTPSVC'
            ServiceState = 'Stopped'
            StartupType  = 'Disabled'
            CheckContent = 'If the server has the role of an FTP server, this is NA.
            Run "Services.msc".
        
            If the "Microsoft FTP Service" (Service name: FTPSVC) is installed and not disabled, this is a finding.'
            ConversionStatus = 'pass'
        },
        @{
            ServiceName  = $null
            ServiceState = 'Stopped'
            StartupType  = 'Disabled'
            CheckContent = 'If the server has the role of a server, this is NA.
            Run "Services.msc".
        
            If A string without parentheses is installed and not disabled, this is a finding.'
            ConversionStatus = 'fail'
        }
    )
    #endregion
    #region Tests
    Describe "Single Service Rule Conversion" {

        foreach ( $service in $servicesToTest)
        {
            Context "Service '$($service.ServiceName)'" {

                [xml] $StigRule = Get-TestStigRule -CheckContent $service.CheckContent -XccdfTitle Windows
                $TestFile = Join-Path -Path $TestDrive -ChildPath 'TextData.xml'
                $StigRule.Save( $TestFile )
                $rule = ConvertFrom-StigXccdf -Path $TestFile

                It "Should return an ServiceRule Object" {
                    $rule.GetType() | Should Be 'ServiceRule'
                }
                It "Should return Service Name '$($service.ServiceName)'" {
                    $rule.ServiceName | Should Be $service.ServiceName
                } 
                It "Should return Service State '$($service.ServiceState)' from '$($service.ServiceName)'" {
                    $rule.ServiceState | Should Be $service.ServiceState
                }
                It "Should return Startup Type '$($service.StartupType)' from '$($service.ServiceName)'" {
                    $rule.StartupType | Should Be $service.StartupType
                }
                It "Should set the Conversion statud to pass ensure value" {
                    $rule.conversionstatus | Should be $service.conversionstatus
                }
            }
        }
    }
    Describe "Multiple Service Rule Conversion" {

        $checkContent = 'Run "services.msc" to display the Services console.
    
    Verify the Startup Type for the following Windows services: 
    - Active Directory Domain Services
    - Windows Time (not required if another time synchronization tool is implemented to start automatically)
    
    If the Startup Type for any of these services is not Automatic, this is a finding'
     
        [xml] $StigRule = Get-TestStigRule -CheckContent $checkContent -XccdfTitle Windows
        $TestFile = Join-Path -Path $TestDrive -ChildPath 'TextData.xml'
        $StigRule.Save( $TestFile )
        $rule = ConvertFrom-StigXccdf -Path $TestFile

        It "Should return Multiple ServiceRule Objects" {
            $rule.Count | Should Be 2
        }

        Context 'First Split Rule' {

            $rule = $rule[-1]

            It "Should return an ServiceRule Object" {
                $rule.GetType() | Should Be 'ServiceRule'
            }
            It "Should append .a to the id" {
                $rule.id | Should Match '^V-.*\.a$'
            }
            It "Should return 'NTDS'" {
                $rule.ServiceName | Should Be 'NTDS'
            } 
            It "Should return 'Running'" {
                $rule.ServiceState | Should Be 'Running'
            }
            It "Should return 'Automatic'" {
                $rule.StartupType | Should Be 'Automatic'
            }
            It "Should set the Conversion statud to pass ensure value" {
                $rule.conversionstatus | Should be 'pass'
            }
        }

        Context 'Second Split Rule' {

            $rule = $rule[-2]

            It "Should return an ServiceRule Object" {
                $rule.GetType() | Should Be 'ServiceRule'
            }
            It "Should append .b to the id" {
                $rule.id | Should Match '^V-.*\.b$'
            }
            It "Should return 'W32Time'" {
                $rule.ServiceName | Should Be 'W32Time'
            } 
            It "Should return 'Running'" {
                $rule.ServiceState | Should Be 'Running'
            }
            It "Should return 'Automatic'" {
                $rule.StartupType | Should Be 'Automatic'
            }
            It "Should set the Conversion statud to pass ensure value" {
                $rule.conversionstatus | Should be 'pass'
            }
        }
    }
    #endregion
}
finally
{
    . $PSScriptRoot\.tests.footer.ps1
}
