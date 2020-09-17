#region Header
. $PSScriptRoot\.tests.header.ps1
#endregion

try
{
    InModuleScope -ModuleName "$($global:moduleName).Convert" {
        #region Test Setup
        $testRuleList = @(
            @{
                Query = "SELECT * FROM Win32_Volume WHERE DriveType = '3' AND SystemVolume != 'True'"
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
            @{
                Query = "SELECT * FROM Win32_OperatingSystem"
                Property = 'Version'
                DesiredValue = '10.0.16299'
                Operator = '-le'
                OrganizationValueRequired = $false
                CheckContent = 'Run "winver.exe".

                If the "About Windows" dialog box does not display:

                "Microsoft Windows Version 1709 (OS Build 16299.0)"

                or greater, this is a  finding.

                Note: Microsoft has extended support for previous versions providing critical and important updates for Windows 10 Enterprise.

                Microsoft scheduled end of support dates for current Semi-Annual Channel versions:
                v1703 - 8 October 2019
                v1709 - 14 April 2020
                v1803 - 10 November 2020
                v1809 - 13 April 2021
                v1903 - 8 December 2020

                No preview versions will be used in a production environment.

                Special purpose systems using the Long-Term Servicing Branch\Channel (LTSC\B) may be at following versions which are not a finding:

                v1507 (Build 10240)
                v1607 (Build 14393)
                v1809 (Build 17763)'
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
