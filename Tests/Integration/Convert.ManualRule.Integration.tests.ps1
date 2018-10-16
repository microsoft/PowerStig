#region Header
. $PSScriptRoot\.tests.header.ps1
#endregion
try
{
    #region Test Setup
    $checkContent = 'Verify servers are located in controlled access areas that are accessible only to authorized personnel.  If systems are not adequately protected, this is a finding.'
    #endregion
    #region Tests
    Describe "Manual Check Conversion" {
        [xml] $stigRule = Get-TestStigRule -CheckContent $checkContent -XccdfTitle Windows
        $TestFile = Join-Path -Path $TestDrive -ChildPath 'TextData.xml'
        $stigRule.Save( $TestFile )
        $rule = ConvertFrom-StigXccdf -Path $TestFile

        It "Should return an ManualRule Object" {
            $rule.GetType() | Should Be 'ManualRule'
        }
    }
    #endregion
}
finally
{
    . $PSScriptRoot\.tests.Footer.ps1
}
