#region Header
using module .\..\..\..\Module\Rule.AuditSetting\Convert\AuditSettingRule.Convert.psm1
. $PSScriptRoot\.tests.header.ps1
#endregion

try
{
    InModuleScope -ModuleName "$($global:moduleName).Convert" {
        #region Test Setup
        $testRuleList = @(
            @{
                Query = "SELECT * FROM Win32_LogicalDisk WHERE DriveType = '3'"
                Property = 'FileSystem'
                DesiredValue = 'NTFS|ReFS'
                Operator = '-match'
                OrganizationValueRequired = $false
                CheckContent = 'Open the Computer Management Console.
                Expand the "Storage" object in the Tree window.
                Select the "Disk Management" object.

                If the file system column does not indicate "NTFS" as the file system for each local hard drive, this is a finding.

                Some hardware vendors create a small FAT partition to store troubleshooting and recovery data. No other files must be stored here.  This
                must be documented with the ISSO.'
            }
        )
        #endregion

        foreach ($testRule in $testRuleList)
        {
            . $PSScriptRoot\Convert.CommonTests.ps1
        }

        #region Add Custom Tests Here

        #endregion
    }
}
finally
{
    . $PSScriptRoot\.tests.footer.ps1
}
