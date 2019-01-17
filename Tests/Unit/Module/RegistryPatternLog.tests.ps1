#region Header
using module .\..\..\..\PowerStig.Convert.psm1
using module .\..\..\..\Module\RegistryRule\RegistryRule.psm1
. $PSScriptRoot\.tests.header.ps1
#endregion

try
{
    InModuleScope -ModuleName "RegistryRule" {
        #region Test Setup
        $folderPath = Resolve-Path -Path '..\..\..\StigData\Archive\browser' -Relative
        $filePath = Resolve-Path -Path '..\..\..\StigData\Archive\browser\U_MS_IE11_STIG_V1R13_Manual-xccdf.xml' -Relative
        #endregion

        #region Class Tests
        #endregion

        #region Method Tests
        Describe "Get-RegistryPatternLog" {

            Context 'Path is directory' {

                It "Shoud return valid table with updated counts" {
                    $result = Get-RegistryPatternLog -Path $folderPath
                    $result.GetType() | Should Be 'System.Object[]'
                }
            }
            Context 'Path is file' {

                It "Shoud return valid table with updated counts" {
                    $result = Get-RegistryPatternLog -Path $filePath
                    $result.GetType() | Should Be 'System.Object[]'
                }
            }
            Context 'Path is null' {

                It "Shoud throw if path is null" {
                { Get-RegistryPatternLog -Path $null } | Should Throw "Cannot bind argument to parameter 'Path' because it is an empty string."
                }
            }
        }
        #endregion

        #region Data Tests
        #endregion
    }
}
finally
{
    . $PSScriptRoot\.tests.footer.ps1
}
