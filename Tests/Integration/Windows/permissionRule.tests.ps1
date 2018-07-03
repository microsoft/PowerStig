#region Header
using module ..\..\..\release\PowerStigConvert\PowerStigConvert.psd1
. $PSScriptRoot\..\..\helper.ps1
#endregion Header
#region Test Setup
$checkContent = 'Verify the permissions on Event Viewer only allow TrustedInstaller permissions to change or
modify.  If any groups or accounts other than TrustedInstaller have Full control or Modify, this
is a finding.

Navigate to "%WinDir%\SYSTEM32".
View the permissions on "{0}".

The default permissions below satisfy this requirement.
{1} - {2}
{3} - {4}
{5} - {6} - {7}
'

$targetExe = 'eventvwr.exe'
$permission1 = 'Full Control'
$permission2 = 'Read &amp; Execute'
$principal1 = 'TrustedInstaller'
$principalList = 'Administrators, SYSTEM, Users, ALL APPLICATION PACKAGES'
$principal2 = 'SystemUsers'
$permission3 = 'Create Folders'
$inheritance = 'This folder, subfolders and files'
#endregion Test Setup
#region Tests
Describe "Permission Rule Multiple Principals, same permissions, same line" {
    
    $checkContent = $checkContent -f $targetExe, $principal1, $permission1, $principalList,
                                     $permission2, $principal2, $permission3, $inheritance
    [xml] $StigRule = Get-TestStigRule -CheckContent $checkContent -XccdfTitle Windows
    $TestFile = Join-Path -Path $TestDrive -ChildPath 'TextData.xml'
    $StigRule.Save( $TestFile )
    $rule = ConvertFrom-StigXccdf -Path $TestFile

    It "Should return a PermissionRule Object" {
        $rule.GetType() | Should Be 'PermissionRule'
    }
    It "Should extract the correct path" {
        $rule.Path | Should Be ('%windir%\SYSTEM32\' + $targetExe)
    }
    It "Should extract the FullControl permission for TrustedInstaller" {
        $principalToTest = $rule.AccessControlEntry | Where-Object Principal -eq 'TrustedInstaller'
        $principalToTest.Rights | Should Be 'FullControl'
    }

    foreach ( $principal in $principalList -split ',' )
    {
        It "Should extract the ReadAndExecute permission for all the principals listed on one line" {
            $principalToTest = $rule.AccessControlEntry | Where-Object Principal -eq $principal.Trim()
            $principalToTest.Rights | Should Be 'ReadAndExecute'
        }
    }
    It "Should extract This folder subfolders and files for inheritance" {
        $principalToTest = $rule.AccessControlEntry | Where-Object Principal -eq $principal2
        $principalToTest.Inheritance | Should Be 'This folder subfolders and files'
    }

    It "Should return NTFSAccessEntry for DscResource" {
        $rule.dscresource | Should Be 'NTFSAccessEntry'
    }
}
#endregion Tests
