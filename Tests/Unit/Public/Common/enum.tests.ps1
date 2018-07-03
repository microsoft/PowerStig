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
#region Tests
<# 
    a list of enums in the script that is used in a "burn down" manner. When an enum is processed
    it is removed from the list, The last test will be to verify that all of the enums have 
    been tested
#>
$enumDiscovered = New-Object System.Collections.ArrayList
# select each line that starts with enum to count the number of enum's in the file 

$enumListString = ( Get-Content $modulePath | Select-String "^Enum " )
# add each enum that is found to the array
$enumListString | Foreach-Object { $enumDiscovered.add( ( $_ -split " " )[1].ToString().ToLower() ) | Out-Null }
# get a count to to use in a final test to validate enum test coverage 
[int] $enumTestCount = $enumDiscovered.Count

$enumTests = @{
    'Process'    = 'auto|manual'
    'Status'     = 'pass|warn|fail'
    'Severity'   = 'low|medium|high'
    'ensure'     = 'Present|Absent'
    'RuleType'   = 'AccountPolicyRule|AuditPolicyRule|DnsServerRootHintRule|DnsServerSettingRule|DocumentRule|GroupRule|IisLoggingRule|ManualRule|MimeTypeRule|PermissionRule|ProcessMitigationRule|RegistryRule|SecurityOptionRule|ServiceRule|SqlScriptQueryRule|UserRightRule|WebConfigurationPropertyRule|WebAppPoolRule|WindowsFeatureRule|WinEventLogRule|WmiRule'
}

foreach( $enum in $enumTests.GetEnumerator() )
{
    Describe "$($enum.Key) Enumeration" {

        $enumDiscovered.Remove( $enum.Key.tolower() )

        # Dump the status enum and verify it is the expected list
        #[process].GetEnumValues()
        $EnumValues = [enum]::GetValues($enum.Key)

        foreach ( $value in $EnumValues ) 
        {
            It "$value should exist" {
                $value | should match $enum.Value
            }
        }
    }
}

# final test to validate all enums habve been tested
Describe 'Enum coverage' {

    it "Should have tested $enumTestCount enum's" {

        # if this test is failing verify that the $enumList.Remove('enum') line is in the
        # describe statemetn for the enum.
	    ( $enumDiscovered.count - $enumTestCount ) * -1 | should be $enumTestCount
    }
}
#endregion Tests
