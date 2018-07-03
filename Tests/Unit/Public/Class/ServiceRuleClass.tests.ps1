using module ..\..\..\..\Public\Class\ServiceRuleClass.psm1
#region HEADER
# Convert Public Class Header V1
using module ..\..\..\..\Public\Common\enum.psm1
. $PSScriptRoot\..\..\..\..\Public\Common\data.ps1
$ruleClassName = ($MyInvocation.MyCommand.Name -Split '\.')[0]

$script:moduleRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)))
$script:moduleName = $MyInvocation.MyCommand.Name -replace '\.tests\.ps1', '.psm1'
$script:modulePath = "$($script:moduleRoot)$(($PSScriptRoot -split 'Unit')[1])\$script:moduleName"
if ( (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'PowerStig.Tests'))) -or `
     (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'PowerStig.Tests\TestHelper.psm1'))) )
{
    & git @('clone','https://github.com/Microsoft/PowerStig.Tests',(Join-Path -Path $script:moduleRoot -ChildPath 'PowerStig.Tests'))
}
Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'PowerStig.Tests' -ChildPath 'TestHelper.psm1')) -Force
#endregion
#region Test Setup
$rule = [ServiceRule]::new( (Get-TestStigRule -ReturnGroupOnly) )

$servicesToTest = @(
    @{
        ServiceName  = 'McAfee'
        ServiceState = 'Running'
        StartupType  = 'Automatic'
        CheckContent = 'Run "Services.msc".
    
        Verify the McAfee Agent service is running, depending on the version installed.
    
        Version - Service Name
        McAfee Agent v5.x - McAfee Agent Service
        McAfee Agent v4.x - McAfee Framework Service
    
        If the service is not listed or does not have a Status of "Started", this is a finding.'
    },
    @{
        ServiceName  = 'SCPolicySvc'
        ServiceState = 'Running'
        StartupType  = 'Automatic'
        CheckContent = 'Verify the Smart Card Removal Policy service is configured to "Automatic".
    
        Run "Services.msc".
    
        If the Startup Type for Smart Card Removal Policy is not set to Automatic, this is a finding.'
    },
    @{
        ServiceName  = 'simptcp'
        ServiceState = 'Stopped'
        StartupType  = 'Disabled'
        CheckContent = 'Verify the Simple TCP/IP (simptcp) service is not installed or is disabled.
    
        Run "Services.msc".
    
        If the following is installed and not disabled, this is a finding:
    
        Simple TCP/IP Services (simptcp)'  
    },
    @{
        ServiceName  = 'FTPSVC'
        ServiceState = 'Stopped'
        StartupType  = 'Disabled'
        CheckContent = 'If the server has the role of an FTP server, this is NA.
        Run "Services.msc".
    
        If the "Microsoft FTP Service" (Service name: FTPSVC) is installed and not disabled, this is a finding.'
    },
    @{
        ServiceName  = $null
        ServiceState = 'Stopped'
        StartupType  = 'Disabled'
        CheckContent = 'If the server has the role of a server, this is NA.
        Run "Services.msc".
    
        If A string without parentheses is installed and not disabled, this is a finding.'
    }
)
#endregion
#region Class Tests
Describe "$ruleClassName Child Class" {
    
    Context 'Base Class' {
        
        It "Shoud have a BaseType of STIG" {
            $rule.GetType().BaseType.ToString() | Should Be 'STIG'
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

    Context 'Class Methods' {
        
        $classMethods = @('SetServiceName', 'SetServiceState', 'SetStartupType')

        foreach ( $method in $classMethods )
        {
            It "Should have a method named '$method'" {
                ( $rule | Get-Member -Name $method ).Name | Should Be $method
            }
        }

        # If new methods are added this will catch them so test coverage can be added
        It "Should not have more methods than are tested" {
            $memberPlanned = Get-StigBaseMethods -ChildClassMethodNames $classMethods
            $memberActual = ( $rule | Get-Member -MemberType Method ).Name
            $compare = Compare-Object -ReferenceObject $memberActual -DifferenceObject $memberPlanned
            $compare.Count | Should Be 0
        }
    }

    Context 'Static Methods' {
        
        $staticMethods = @('HasMultipleRules', 'SplitMultipleRules')

        foreach ( $method in $staticMethods )
        {    
            It "Should have a method named '$method'" {
                ( [ServiceRule] | Get-Member -Static -Name $method ).Name | Should Be $method
            } 
        }
        # If new methods are added this will catch them so test coverage can be added
        It "Should not have more static methods than are tested" {
            $memberPlanned = Get-StigBaseMethods -Static -ChildClassMethodNames $staticMethods
            $memberActual = ( [ServiceRule] | Get-Member -Static -MemberType Method ).Name
            $compare = Compare-Object -ReferenceObject $memberActual -DifferenceObject $memberPlanned
            $compare.Count | Should Be 0
        }
    }

}
#endregion
#region Method function Tests
Describe 'Get-ServiceName' {

    foreach ( $service in $servicesToTest )
    {
        It "Should return '$($service.ServiceName)'" {
            $serviceName = Get-ServiceName -CheckContent ($service.CheckContent -split '\n')
            $serviceName | Should Be $service.ServiceName
        } 
    }
}

Describe 'Get-ServiceState' {

    foreach ( $service in $servicesToTest )
    {
        It "Should return '$($service.ServiceState)' from '$($service.ServiceName)'" {
            $serviceState = Get-ServiceState -CheckContent ($service.CheckContent -split '\n')
            $serviceState | Should Be $service.ServiceState
        } 
    }
}

Describe 'Get-ServiceStartupType' {

    foreach ( $service in $servicesToTest )
    {
        It "Should return '$($service.StartupType)' from '$($service.ServiceName)'" {
            $StartupType = Get-ServiceStartupType -CheckContent ($service.CheckContent -split '\n')
            $StartupType | Should Be $service.StartupType
        } 
    }
}

Describe 'Test-MultipleServiceRule' {
    
        It "Should return $true if a Multiple Services are found " {
            Test-MultipleServiceRule -ServiceName "NTDS,DFSR,DNS,W32Time" | Should Be $true
        }
        It "Should return $false if a comma is found " {
            Test-MultipleServiceRule -ServiceName "service" | Should Be $false
        }
        It "Should return $false if a null value is passed" {
            Test-MultipleServiceRule -ServiceName $null | Should Be $false
        }
        It "Should not thrown an error if a null value is passed" {
            {Test-MultipleServiceRule -ServiceName $null} | Should Not Throw
        }
    }
#endregion
