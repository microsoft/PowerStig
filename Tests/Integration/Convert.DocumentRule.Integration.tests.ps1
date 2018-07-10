#region Header
. $PSScriptRoot\.tests.Header.ps1
#endregion
try
{
    #region Test Setup
    #endregion
    #region Tests
    Describe 'Document Rule' {

        It "Should have valid tests" {
            $true | Should Be $False
        }
    }
    #endregion
}
finally
{
    . $PSScriptRoot\.tests.Footer.ps1
}
