#region Header
using module .\..\..\..\Module\STIG.Checklist\STIG.Checklist.psm1
. $PSScriptRoot\.tests.header.ps1
#endregion
try
{
    InModuleScope -ModuleName $script:moduleName {
        #region Test Setup

        #endregion
        #region Tests

        Describe 'New-StigCheckList' {

        }
        #endregion
    }
}
finally
{
    . $PSScriptRoot\.tests.footer.ps1
}
