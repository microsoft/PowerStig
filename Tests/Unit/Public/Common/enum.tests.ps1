#region Header
. $PSScriptRoot\..\..\..\helper.ps1
[string] $sut = $MyInvocation.MyCommand.Path -replace '\\tests\\','\src\' `
                                             -replace '\.tests','' `
                                             -replace '\\unit\\','\' `
                                             -replace 'ps1', 'psm1'
#endregion
#region Setup

#endregion
#region Tests
<# 
    a list of enums in the script that is used in a "burn down" manner. When an enum is processed
    it is removed from the list, The last test will be to verify that all of the enums have 
    been tested
#>
$enumDiscovered = New-Object System.Collections.ArrayList
# select each line that starts with enum to count the number of enum's in the file 

$enumListString = ( Get-Content $sut | Select-String "^Enum " )
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
