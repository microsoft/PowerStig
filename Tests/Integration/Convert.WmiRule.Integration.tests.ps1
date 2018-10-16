#region Header
. $PSScriptRoot\.tests.header.ps1
#endregion
try
{
    #region Test Setup
    $checkContent = 'Open the Computer Management Console.
    Expand the "Storage" object in the Tree window.
    Select the "Disk Management" object.

    If the file system column does not indicate "NTFS" as the file system for each local hard drive, this is a finding.

    Some hardware vendors create a small FAT partition to store troubleshooting and recovery data. No other files must be stored here.  This 
    must be documented with the ISSO.'
    #endregion
    #region Tests
    Describe "Wmi Rule Conversion" {
        [xml] $stigRule = Get-TestStigRule -CheckContent $checkContent -XccdfTitle Windows
        $TestFile = Join-Path -Path $TestDrive -ChildPath 'TextData.xml'
        $stigRule.Save( $TestFile )
        $rule = ConvertFrom-StigXccdf -Path $TestFile

        It "Should return an WmiRule Object" {
            $rule.GetType() | Should Be 'WmiRule'
        }
        It "Should extract the correct Query" {
            $rule.Query | Should Be "SELECT * FROM Win32_LogicalDisk WHERE DriveType = '3'"
        }
        It "Should extract the correct Property Name" {
            $rule.Property | Should be 'FileSystem'
        }
        It "Should set the correct Value" {
            $rule.Value | Should be 'NTFS|ReFS'
        }
        It "Should set the correct Operator" {
            $rule.Operator | Should be '-match'
        }
        It 'Should Set the status to pass' {
            $rule.conversionstatus | Should Be 'pass'
        }
    }
    #endregion
}
finally
{
    . $PSScriptRoot\.tests.footer.ps1
}
