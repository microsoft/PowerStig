using module ..\..\..\..\Public\class\IisLoggingRuleClass.psm1
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
$rule = [IisLoggingRule]::new( (Get-TestStigRule -ReturnGroupOnly) )

$iisLoggingRules = @(
    @{
        LogFlags = 'Date,Time,ClientIP,UserName,Method,UriQuery,ProtocolVersion,Referer'
        LogFormat = $null
        LogPeriod = $null
        LogTargetW3C = $null
          CheckContent  = 'Follow the procedures below for each site hosted on the IIS 8.5 web server:

        Open the IIS 8.5 Manager.
        
        Click the site name.
        
        Click the "Logging" icon.
        
        Under Format select "W3C".
        
        Click Select Fields, verify at a minimum the following fields are checked: Date, Time, Client IP Address, User Name, Method, URI Query, Protocol Status, and Referrer.
        
        If the "W3C" is not selected as the logging format OR any of the required fields are not selected, this is a finding.'
    }
    @{
        LogFlags = 'UserAgent,UserName,Referer'
        LogFormat = 'W3C'
        LogPeriod = $null
        LogTargetW3C = $null
          CheckContent  = 'Follow the procedures below for each site hosted on the IIS 8.5 web server:

          Access the IIS 8.5 web server IIS 8.5 Manager.
          
          Under "IIS", double-click the "Logging" icon.
          
          Verify the "Format:" under "Log File" is configured to "W3C".
          
          Select the "Fields" button.
          
          Under "Standard Fields", verify "User Agent", "User Name" and "Referrer" are selected.
          
          Under "Custom Fields", verify the following fields have been configured: 
          
          Server Variable >> HTTP_USER_AGENT
          
          Request Header >> User-Agent
          
          Request Header >> Authorization
          
          Response Header >> Content-Type
          
          If any of the above fields are not selected, this is a finding.'
    }
    @{
        LogFlags = $null
        LogFormat = $null
        LogPeriod = $null
        LogTargetW3C = 'File,ETW'
          CheckContent  = 'Follow the procedures below for each site hosted on the IIS 8.5 web server:

          Open the IIS 8.5 Manager.
          
          Click the site name.
          
          Click the "Logging" icon.
          
          Under Log Event Destination, verify the "Both log file and ETW event" radio button is selected.
          
          If the "Both log file and ETW event" radio button is not selected, this is a finding.'
    }
    @{
        LogFlags = $null
        LogFormat = $null
        LogPeriod = 'daily'
        LogTargetW3C = $null
          CheckContent  = 'Follow the procedures below for each site hosted on the IIS 8.5 web server:

          Access the IIS 8.5 web server IIS 8.5 Manager.
          
          Under "IIS" double-click on the "Logging" icon.
          
          In the "Logging" configuration box, determine the "Directory:" to which the "W3C" logging is being written.
          
          Confirm with the System Administrator that the designated log path is of sufficient size to maintain the logging.
          
          Under "Log File Rollover", verify the "Do not create new log files" is not selected.
          
          Verify a schedule is configured to rollover log files on a regular basis.
          
          Consult with the System Administrator to determine if there is a documented process for moving the log files off of the IIS 8.5 web server to another logging device.'
    }
)

$customLogEntries = @(
    @{
        LogCustomFieldEntry = @(
            @{
                SourceType = 'ServerVariable'
                SourceName = 'HTTP_USER_AGENT'
            }
            @{
                SourceType = 'RequestHeader'
                SourceName = 'User-Agent'
            }
            @{
                SourceType = 'RequestHeader'
                SourceName = 'Authorization'
            }
            @{
                SourceType = 'ResponseHeader'
                SourceName = 'Content-Type'
            }
        )
          CheckContent  = 'Follow the procedures below for each site hosted on the IIS 8.5 web server:

          Access the IIS 8.5 web server IIS 8.5 Manager.
          
          Under "IIS", double-click the "Logging" icon.
          
          Verify the "Format:" under "Log File" is configured to "W3C".
          
          Select the "Fields" button.
          
          Under "Standard Fields", verify "User Agent", "User Name" and "Referrer" are selected.
          
          Under "Custom Fields", verify the following fields have been configured: 
          
          Server Variable >> HTTP_USER_AGENT
          
          Request Header >> User-Agent
          
          Request Header >> Authorization
          
          Response Header >> Content-Type
          
          If any of the above fields are not selected, this is a finding.'
    }
)

#endregion Test Setup

#region Class Tests
Describe "$ruleClassName Child Class" {
    
    Context 'Base Class' {
        
        It "Shoud have a BaseType of STIG" {
            $rule.GetType().BaseType.ToString() | Should Be 'STIG'
        }
    }

    Context 'Class Properties' {
        
        $classProperties = @('LogCustomFieldEntry', 'LogFlags', 'LogFormat', 'LogPeriod', 'LogTargetW3c')

        foreach ( $property in $classProperties )
        {
            It "Should have a property named '$property'" {
                ( $rule | Get-Member -Name $property ).Name | Should Be $property
            }
        }
    }

    Context 'Class Methods' {
        
        $classMethods = @('SetLogCustomFields', 'SetLogFlags', 'SetLogFormat', 'SetLogPeriod'
            'SetLogTargetW3c', 'SetStatus')

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
}
#endregion Class Tests

#region Method function Tests
foreach ( $iisLoggingRule in $iisLoggingRules )
{
    Describe 'Get-LogFlag' {
        It "Should return $($iisLoggingRule.LogFlags)" {
            $logFlag = Get-LogFlag -CheckContent ($iisLoggingRule.CheckContent -split '\n')
            $logFlag | Should Be $iisLoggingRule.LogFlags
        } 
    }

    Describe 'Get-LogFormat' {
        It "Should return $($iisLoggingRule.LogFormat)" {
            $logFormat = Get-LogFormat -CheckContent ($iisLoggingRule.CheckContent -split '\n')
            $logFormat | Should Be $iisLoggingRule.LogFormat
        } 
    }

    Describe 'Get-LogPeriod' {
        It "Should return $($iisLoggingRule.LogPeriod)" {
            $logPeriod = Get-LogPeriod -CheckContent ($iisLoggingRule.CheckContent -split '\n')
            $logPeriod | Should Be $iisLoggingRule.LogPeriod
        } 
    }

    Describe 'Get-LogTargetW3C' {
        It "Should return $($iisLoggingRule.LogTargetW3C)" {
            $logTargetW3C = Get-LogTargetW3C -CheckContent ($iisLoggingRule.CheckContent -split '\n')
            $logTargetW3C | Should Be $iisLoggingRule.LogTargetW3C
        } 
    }
}

foreach ($entry in $customLogEntries)
{
    Describe 'Get-LogCustomFieldEntry' {
        It "Should return expected LogCustomFieldEntry object" {
            $logCustomFieldEntry = Get-LogCustomFieldEntry -CheckContent ($entry.CheckContent -split '\n')
            $compare = Compare-Object -ReferenceObject $logCustomFieldEntry -DifferenceObject $entry.LogCustomFieldEntry
            $compare.Count | Should Be 0
        } 
    }    
}
#endregion Method function Tests
