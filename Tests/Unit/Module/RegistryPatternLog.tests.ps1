#region Header
using module .\..\..\..\Module\RegistryRule\RegistryRule.psm1
. $PSScriptRoot\.tests.header.ps1
$expressionFileList = Get-Item .\..\..\..\Module\Convert.Main\Data.*.ps1
foreach ($supportFile in $expressionFileList)
{
    Write-Verbose "Loading $($supportFile.FullName)"
    . $supportFile.FullName
}
#endregion

Import-Module .\PowerStig.Convert.psm1
#Import-Module .\Module\RegistryRule\RegistryRule.psm1
#TESTING DIRECTORY
#Get-RegistryPatternLog "C:\Users\ladillon\Source\Repos\PowerStig\StigData\Archive\browser"
#TESTING FILE
Get-RegistryPatternLog "C:\Users\ladillon\Source\Repos\PowerStig\StigData\Archive\browser\U_MS_IE11_STIG_V1R13_Manual-xccdf.xml"



<# try
{
    InModuleScope -ModuleName $script:moduleName {
        #region Test Setup
        $folderPath = ..\..\StigData\Archive
        $filePath = ..\..\StigData\Archive\Windows.Client\U_Windows_10_STIG_V1R14_Manual-xccdf.xml
        #endregion
        #region Class Tests

        #endregion
        #region Method Tests
        Describe "Get-RegistryPatternLog" {

            Context 'Path is directory' {

                It "Shoud return valid table with updated counts" {
                    $result = Get-RegistryPatternLog -Path $folderPath
                    $result.GetType() | Should Be 'System.Collection.Specialized.OrderedDictionary'
                }
            }
            Context 'Path is file' {

                It "Shoud return valid table with updated counts" {
                    $result = Get-RegistryPatternLog -Path $filePath
                    $result.GetType() | Should Be 'System.Collection.Specialized.OrderedDictionary'
                }
            }
            Context 'Path is null' {

                It "Shoud return null" {
                    $result = Get-RegistryPatternLog -Path $null
                    $result | Should Be $null
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
 #>