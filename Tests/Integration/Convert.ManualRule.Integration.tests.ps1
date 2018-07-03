#region Header
using module ..\..\..\release\PowerStigConvert\PowerStigConvert.psd1
. $PSScriptRoot\..\..\helper.ps1
#endregion Header
#regionTest Setup
$checkContent = 'Verify servers are located in controlled access areas that are accessible only to authorized personnel.  If systems are not adequately protected, this is a finding.'
#endregion Test Setup
#region Tests
Describe "Manual Check Conversion" {
    [xml] $StigRule = Get-TestStigRule -CheckContent $checkContent -XccdfTitle Windows
    $TestFile = Join-Path -Path $TestDrive -ChildPath 'TextData.xml'
    $StigRule.Save( $TestFile )
    $rule = ConvertFrom-StigXccdf -Path $TestFile

    It "Should return an ManualRule Object" {
        $rule.GetType() | Should Be 'ManualRule'
    }
}
#endregion Tests
