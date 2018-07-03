#region HEADER
. $PSScriptRoot\.Convert.Test.Header.ps1
#endregion
#region Test Setup
$checkContent = 'Open the Computer Management Console.
Expand the "Storage" object in the Tree window.
Select the "Disk Management" object.

If the file system column does not indicate "NTFS" as the file system for each local hard drive, this is a finding.

Some hardware vendors create a small FAT partition to store troubleshooting and recovery data. No other files must be stored here.  This
must be documented with the ISSO.'
#endregion
#region Tests
Describe "ConvertTo-WmiRule" {
    <#
        This function can't really be unit tested, since the call cannot be mocked by pester, so
        the only thing we can really do at this point is to verify that it returns the correct object.
    #>
    $stigRule = Get-TestStigRule -CheckContent $checkContent -ReturnGroupOnly
    $rule = ConvertTo-WmiRule -StigRule $stigRule

    It "Should return an WmiRule object" {
        $rule.GetType() | Should Be 'WmiRule'
    }
}
#########################################      Tests       #########################################
