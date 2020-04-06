#region Header
. $PSScriptRoot\.tests.header.ps1
$setDynamicClassFileParams = @{
    ClassModuleFileName = 'RegistryRule.Convert.psm1'
    PowerStigBuildPath  = $script:moduleRoot
    DestinationPath     = (Join-Path -Path $PSScriptRoot -ChildPath '..\.DynamicClassImport\RegistryRule.Convert.ps1')
}
Set-DynamicClassFile @setDynamicClassFileParams
. $setDynamicClassFileParams.DestinationPath

# Data files
$dataFilePath = Join-Path -Path $script:moduleRoot -ChildPath 'Module\Rule\Convert'
$supportFiles = (Get-ChildItem -Path $dataFilePath -Filter 'Data.*.ps1').FullName
foreach ($file in $supportFiles)
{
    . $file
}
#endregion

try
{
    InModuleScope -ModuleName "$($global:moduleName).Convert" {
        #region Test Setup
        $testRuleList = @(
            @{
                Key = 'HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\WindowsMediaPlayer'
                ValueData = '1'
                ValueName = 'GroupPrivacyAcceptance'
                ValueType = 'DWORD'
                Ensure = 'Present'
                OrganizationValueRequired = $false
                CheckContent = 'Windows Media Player is not installed by default.  If it is not installed, this is NA.

                    If the following registry value does not exist or is not configured as specified, this is a finding:

                    Registry Hive: HKEY_LOCAL_MACHINE
                    Registry Path: \Software\Policies\Microsoft\WindowsMediaPlayer\

                    Value Name: GroupPrivacyAcceptance

                    Type: REG_DWORD
                    Value: 1'
            },
            @{
                Key = 'HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\W32Time\Config'
                ValueData = $null
                ValueName = 'EventLogFlags'
                ValueType = 'DWORD'
                Ensure = 'Present'
                OrganizationValueRequired = $true
                OrganizationValueTestString = "'{0}' -match '2|3'"
                CheckContent = 'Verify logging is configured to capture time source switches.

                    If the Windows Time Service is used, verify the following registry value.  If it is not configured as specified, this is a finding.

                    Registry Hive: HKEY_LOCAL_MACHINE
                    Registry Path: \System\CurrentControlSet\Services\W32Time\Config\

                    Value Name: EventLogFlags

                    Type: REG_DWORD
                    Value: 2 or 3

                    If another time synchronization tool is used, review the available configuration options and logs.  If the tool has time source logging capability and it is not enabled, this is a finding.'
            },
            @{
                Key = 'HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Subsystems'
                ValueData = ''
                ValueName = 'Optional'
                ValueType = 'MultiString'
                Ensure = 'Present'
                OrganizationValueRequired = $false
                CheckContent = 'If the following registry value does not exist or is not configured as specified, this is a finding:

                    Registry Hive: HKEY_LOCAL_MACHINE
                    Registry Path: \System\CurrentControlSet\Control\Session Manager\Subsystems\

                    Value Name: Optional

                    Value Type: REG_MULTI_SZ
                    Value: (Blank)'
            },
            @{
                Key = 'HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion\Winlogon'
                ValueData = $null
                ValueName = 'ScreenSaverGracePeriod'
                ValueType = 'String'
                Ensure = 'Present'
                OrganizationValueRequired = $true
                OrganizationValueTestString = "'{0}' -le '5'"
                CheckContent = 'If the following registry value does not exist or is not configured as specified, this is a finding:

                    Registry Hive: HKEY_LOCAL_MACHINE
                    Registry Path: \Software\Microsoft\Windows NT\CurrentVersion\Winlogon\

                    Value Name: ScreenSaverGracePeriod

                    Value Type: REG_SZ
                    Value: 5 (or less)'
            },
            @{
                Key = 'HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Lsa\MSV1_0'
                ValueData = '537395200'
                ValueName = 'NTLMMinServerSec'
                ValueType = 'DWORD'
                Ensure = 'Present'
                OrganizationValueRequired = $false
                CheckContent = 'If the following registry value does not exist or is not configured as specified, this is a finding:

                    Registry Hive: HKEY_LOCAL_MACHINE
                    Registry Path: \System\CurrentControlSet\Control\Lsa\MSV1_0\

                    Value Name: NTLMMinServerSec

                    Value Type: REG_DWORD
                    Value: 0x20080000 (537395200)'
            },
            @{
                Key = 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa'
                ValueName = 'RestrictRemoteSAM'
                ValueData = 'O:BAG:BAD:(A;;RC;;;BA)'
                ValueType = 'String'
                Ensure = 'Present'
                OrganizationValueRequired = $false
                CheckContent = 'This is NA prior to v1607 of Windows 10.

                    If the following registry value does not exist or is not configured as specified, this is a finding:

                    Registry Hive: HKEY_LOCAL_MACHINE
                    Registry Path: \SYSTEM\CurrentControlSet\Control\Lsa\

                    Value Name: RestrictRemoteSAM

                    Value Type: REG_SZ
                    Value: O:BAG:BAD:(A;;RC;;;BA)'
            },
            @{
                Key = 'HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Attachments'
                ValueName = 'SaveZoneInformation'
                ValueData = $null
                ValueType = 'Dword'
                Ensure = 'Present'
                OrganizationValueRequired = $true
                OrganizationValueTestString = "'{0}' -match '2|ShouldBeAbsent'"
                CheckContent = 'The default behavior is for Windows to mark file attachments with their zone information.

                    If the registry Value Name below does not exist, this is not a finding.

                    If it exists and is configured with a value of "2", this is not a finding.

                    If it exists and is configured with a value of "1", this is a finding.

                    Registry Hive: HKEY_CURRENT_USER
                    Registry Path: \SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Attachments\

                    Value Name: SaveZoneInformation

                    Value Type: REG_DWORD
                    Value: 0x00000002 (2) (or if the Value Name does not exist)'
            },
            @{
                Key = 'HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Print\Providers\LanMan Print Services\Servers'
                ValueName = 'AddPrinterDrivers'
                ValueData = '1'
                ValueType = 'Dword'
                Ensure = 'Present'
                OrganizationValueRequired = $false
                CheckContent = 'If the following registry value does not exist or is not configured as specified, this is a finding:

                Registry Hive: HKEY_LOCAL_MACHINE
                Registry Path: \System\CurrentControlSet\Control\Print\Providers\LanMan Print Services\Servers\

                Value Name: AddPrinterDrivers

                Value Type: REG_DWORD
                Value: 1'
            },
            @{
                Key = 'HKEY_CURRENT_USER\Software\Policies\Microsoft\Office\16.0\excel\security\fileblock'
                ValueName = 'XL4Workbooks'
                ValueData = '2'
                ValueType = 'Dword'
                Ensure = 'Present'
                OrganizationValueRequired = $false
                CheckContent = 'Verify the policy value for User Configuration -&gt; Administrative Templates -&gt; Microsoft Excel 2016 -&gt; Excel Options -&gt; Security -&gt; Trust Center -&gt; File Block Settings "Excel 4 workbooks" is set to "Enabled: Open/Save blocked, use open policy".

                Procedure: Use the Windows Registry Editor to navigate to the following key:

                HKCU\Software\Policies\Microsoft\Office\16.0\excel\security\fileblock

                Criteria: If the value XL4Workbooks is REG_DWORD = 2, this is not a finding.'
            }
        )
        #endregion

        foreach ($testRule in $testRuleList)
        {
            . $PSScriptRoot\Convert.CommonTests.ps1
        }

        #region Add Custom Tests Here
        Describe 'MultipleRules' {
            # TODO move this to the CommonTests
            $testRuleList = @(
                @{
                    Hive = 'HKEY_LOCAL_MACHINE'
                    Path = '\SOFTWARE\Classes\batfile\shell\runasuser', '\SOFTWARE\Classes\cmdfile\shell\runasuser', '\SOFTWARE\Classes\exefile\shell\runasuser', '\SOFTWARE\Classes\mscfile\shell\runasuser'
                    OrganizationValueRequired = 'False'
                    ValueName = 'SuppressionPolicy'
                    ValueData = '4096'
                    ValueType = 'Dword'
                    Count = 4
                    CheckContent = 'If the following registry values do not exist or are not configured as specified, this
                                                is a finding.
                                                The policy configures the same Value Name, Type and Value under four different registry
                                                paths.

                                                Registry Hive:  HKEY_LOCAL_MACHINE
                                                Registry Paths:
                                                \SOFTWARE\Classes\batfile\shell\runasuser\
                                                \SOFTWARE\Classes\cmdfile\shell\runasuser\
                                                \SOFTWARE\Classes\exefile\shell\runasuser\
                                                \SOFTWARE\Classes\mscfile\shell\runasuser\

                                                Value Name:  SuppressionPolicy

                                                Type:  REG_DWORD
                                                Value:  0x00001000 (4096)'
                },
                @{
                    #multipleRegistryHiveString
                    Count = 2
                    CheckContent = 'This applies to a server

                    If the following registry values are not configured as specified, this is a finding:

                    Registry Hive: HKEY_LOCAL_MACHINE
                    Registry Path: \Path\ToTheFirstValue\To\Set\

                    Value Name: SettingOneName

                    Type: REG_SZ
                    Value: ValueOne

                    Registry Hive: HKEY_LOCAL_MACHINE
                    Registry Path: \Path\ToTheSecondValue\To\Set\

                    Value Name: SettingTwoName

                    Type: REG_DWORD
                    Value: ValueTwo'
                },
                @{
                    #multipleRegistryPathString
                    Count = 2
                    CheckContent = 'Determine if the setting is correct.

                    If they are not configured as specified, this is a finding.

                    Registry Hive: HKEY_LOCAL_MACHINE

                    Registry Path: \Path\ToTheFirstValue\To\Set\
                    Value Name: SettingOneName
                    Type: REG_SZ
                    Value: ValueOne

                    Registry Path: \Path\ToTheSecondValue\To\Set\
                    Value Name: SettingTwoName
                    Type: REG_DWORD
                    Value: ValueTwo

                    If it is not enabled and no alternate tool is enabled, this is a finding.'
                },
                @{
                    #multipleRegistryValueString
                    Count = 2
                    CheckContent = 'Review the following registry values:

                    Registry Hive: HKEY_LOCAL_MACHINE
                    Registry Path: \Path\ToTheFirstValue\To\Set\

                    Value Name: SettingOneName
                    Type: REG_SZ
                    Value: ValueOne

                    and

                    Value Name: SettingTwoName
                    Type: REG_DWORD
                    Value: ValueTwo'
                }
            )

            foreach ($testRule in $testRuleList)
            {
                It "Should return $true" {
                    $multipleRule = [RegistryRuleConvert]::HasMultipleRules($testRule.CheckContent)
                    $multipleRule | Should -Be $true
                }
                It "Should return $($testRule.Count) rules" {
                    $multipleRule = [RegistryRuleConvert]::SplitMultipleRules($testRule.CheckContent)
                    $multipleRule.count | Should -Be $testRule.Count
                }
            }
        }
        Describe 'Match Static method' {

            $stringsToTest = @(
                @{
                    string = 'Navigate to "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\NTDS\Parameters".

                    Note the directory locations in the values for "DSA Database file".

                    Open "Command Prompt".'
                    match = $false
                }
            )

            It 'Should not match the DSA Database file registry path' {
                [RegistryRuleConvert]::Match($stringsToTest.string) | Should -Be $false
            }
        }
        Describe 'Test-RegistryValueDataContainsRange' {

            $rangeStrings = @(
                'Value: 1 or 2 = a Finding',
                'Value:  3 (or less)',
                'Value: 300000 (or less)',
                'Value: 30 (or less, but not 0)',
                'Value: 0x000dbba0 (900000) or less but not 0',
                'Value: 0x0000001e (30) (or less, but not 0)',
                'Value: 0x0000001e (30) (or less, excluding 0)',
                'Value: 0x00000384 (900) (or less, excluding "0" which is effectively disabled)',
                'Value: Possible values are NoSync,NTP,NT5DS, AllSync',
                'Value: 0x00000002 (2) (or if the Value Name does not exist)'
            )

            foreach ($string in $rangeStrings)
            {
                It "Should return true when given '$string'" {
                    $containsRange = Test-RegistryValueDataContainsRange -ValueDataString $string
                    $containsRange | Should -Be $true
                }
            }
        }
        #endregion
    }
}
finally
{
    . $PSScriptRoot\.tests.footer.ps1
}
