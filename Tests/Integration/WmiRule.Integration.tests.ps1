#region Header
. $PSScriptRoot\.tests.header.ps1
#endregion
try
{
    #region Test Setup
    $rulesToTest = @(
            @{
                query        = "SELECT * FROM Win32_LogicalDisk WHERE DriveType = '3'"
                property     = 'FileSystem'
                value        = 'NTFS|ReFS'
                operator     = '-match'
                checkContent = 'Open the Computer Management Console.
    Expand the "Storage" object in the Tree window.
    Select the "Disk Management" object.

    If the file system column does not indicate "NTFS" as the file system for each local hard drive, this is a finding.

    Some hardware vendors create a small FAT partition to store troubleshooting and recovery data. No other files must be stored here.  This
    must be documented with the ISSO.'
            },
            @{
                query        = "SELECT * FROM Win32_OperatingSystem"
                property     = 'Version'
                value        = '10.0.14393'
                operator     = '-ge'
                checkContent = 'Open "Command Prompt".

                Enter "winver.exe".

                If the "About Windows" dialog box does not display "Microsoft Windows Server Version 1607 (Build 14393.xxx)" or greater, this is a finding.

                Preview versions must not be used in a production environment.'
            },
            @{
                query        = "SELECT * FROM Win32_OperatingSystem"
                property     = 'Version'
                value        = '10.0.14393'
                operator     = '-ge'
                checkContent = 'Run "winver.exe".

                If the "About Windows" dialog box does not display:

                "Microsoft Windows Version 1607 (OS Build 14393.0)"

                or greater, this is a finding.

                Note: Microsoft has extended support for previous versions providing critical and important updates for Windows 10 Enterprise.

                Currently supported Semi-Annual Channel versions:
                v1607 - Microsoft support is scheduled to end 09 April 2019.
                v1703 - Microsoft support is scheduled to end 08 October 2019.
                v1709 - Microsoft support is scheduled to end 14 April 2020.
                v1803 - Microsoft support is scheduled to end 10 November 2020.
                v1809 - Microsoft support is scheduled to end 13 April 2021.

                No preview versions will be used in a production environment.

                Special purpose systems using the Long-Term Servicing Branch\Channel (LTSC\B) may be at the following versions, which are not a finding:

                v1507 (Build 10240)
                v1607 (Build 14393)
                v1809 (Build 17763)'
            },@{
                query        = "SELECT * FROM Win32_OperatingSystem"
                property     = 'Version'
                value        = '6.2.9200'
                operator     = '-ge'
                checkContent = 'Run "winver.exe".

                If the "About Windows" dialog box does not display
                "Microsoft Windows Server
                Version 6.2 (Build 9200)"
                or greater, this is a finding.

                No preview versions will be used in a production environment.

                Unsupported Service Packs/Releases:
                Windows 2012 - any release candidates or versions prior to the initial release.'
            }
    )

    #endregion
    #region Tests
    Describe 'AuditSetting Rule Conversion' {

        foreach ( $testRule in $rulesToTest )
        {
            [xml] $stigRule = Get-TestStigRule -CheckContent $testRule.checkContent -XccdfTitle Windows
            $TestFile = Join-Path -Path $TestDrive -ChildPath 'TextData.xml'
            $stigRule.Save( $TestFile )
            $rule = ConvertFrom-StigXccdf -Path $TestFile

            It 'Should return an AuditSettingRule Object' {
                $rule.GetType() | Should Be 'AuditSettingRule'
            }
            It 'Should extract the correct Query' {
                $rule.Query | Should Be $testRule.query
            }
            It 'Should extract the correct Property Name' {
                $rule.Property | Should Be $testRule.property
            }
            It 'Should set the correct Value' {
                $rule.Value | Should Be $testRule.value
            }
            It 'Should set the correct Operator' {
                $rule.Operator | Should Be $testRule.operator
            }
            It "Should set the correct DscResource" {
                $rule.DscResource | Should Be 'Script'
            }
            It 'Should Set the status to pass' {
                $rule.conversionstatus | Should Be 'pass'
            }
        }
    }
    #endregion
}
finally
{
    . $PSScriptRoot\.tests.footer.ps1
}
