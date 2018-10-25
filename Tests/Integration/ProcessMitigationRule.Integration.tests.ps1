#region Header
. $PSScriptRoot\.tests.header.ps1
#endregion
try
{
    #region Test Setup
    $mitigationsRulesToTest = @(
        @{
            MitigationTarget = 'System'
            Enable           = 'TerminateOnError'
            Disable          = $null
            CheckContent     = ' This is NA prior to v1709 of Windows 10.

            Run "Windows PowerShell" with elevated privileges (run as administrator).

            Enter "Get-ProcessMitigation -System".

            If the status of "Heap: TerminateOnError" is "OFF", this is a finding.

            Values that would not be a finding include:
            ON
            NOTSET'
        }
        @{
            MitigationTarget = 'wordpad.exe'
            Enable           = 'Dep', 'EnableExportAddressFilter', 'EnableExportAddressFilterPlus', 'EnableImportAddressFilter', 'EnableRopStackPivot', 'EnableRopCallerCheck', 'EnableRopSimExec'
            Disable          = $null
            CheckContent     = 'This is NA prior to v1709 of Windows 10.

            Run "Windows PowerShell" with elevated privileges (run as administrator).

            Enter "Get-ProcessMitigation -Name wordpad.exe".
            (Get-ProcessMitigation can be run without the -Name parameter to get a list of all application mitigations configured.)

            If the following mitigations do not have a status of "ON", this is a finding:f "ON", this is a finding:

            DEP:
            Enable: ON

            Payload:
            EnableExportAddressFilter: ON
            EnableExportAddressFilterPlus: ON
            EnableImportAddressFilter: ON
            EnableRopStackPivot: ON
            EnableRopCallerCheck: ON
            EnableRopSimExec: ON

            The PowerShell command produces a list of mitigations; only those with a required status of "ON" are listed here.'
        }
        @{
            MitigationTarget = 'java.exe,javaw.exe,javaws.exe'
            Enable           = 'DEP,EnableExportAddressFilter,EnableExportAddressFilterPlus,EnableImportAddressFilter,EnableRopStackPivot,EnableRopCallerCheck,EnableRopSimExec'
            Disable          = $null
            SplitRule        = $true
            CheckContent     = 'This is NA prior to v1709 of Windows 10.

            Run "Windows PowerShell" with elevated privileges (run as administrator).

            Enter "Get-ProcessMitigation -Name [application name]" with each of the following substituted for [application name]:
            java.exe, javaw.exe, and javaws.exe
            (Get-ProcessMitigation can be run without the -Name parameter to get a list of all application mitigations configured.)

            If the following mitigations do not have a status of "ON" for each, this is a finding:

            DEP:
            Enable: ON

            Payload:
            EnableExportAddressFilter: ON
            EnableExportAddressFilterPlus: ON
            EnableImportAddressFilter: ON
            EnableRopStackPivot: ON
            EnableRopCallerCheck: ON
            EnableRopSimExec: ON

            The PowerShell command produces a list of mitigations; only those with a required status of "ON" are listed here.'
        }
    )
    #endregion
    #region Tests
    Describe 'ProcessMitigation Integration Tests' {
        foreach ($mitigationsRule in $mitigationsRulesToTest)
        {
            [xml] $stigRule = Get-TestStigRule -CheckContent $mitigationsRule.CheckContent -XccdfTitle Windows
            $TestFile = Join-Path -Path $TestDrive -ChildPath 'TextData.xml'
            $stigRule.Save( $TestFile )
            $rules = ConvertFrom-StigXccdf -Path $TestFile

            foreach ( $rule in $rules)
            {
                It 'Should return an ProcessMitigationRule Object' {
                    $rule.GetType() | Should Be 'ProcessMitigationRule'
                }

                if ( ($mitigationsRule.MitigationTarget -split ',').Count -gt 1 )
                {
                    It 'Should have a MitigationTarget in the desired MitigationTargetList' {
                        $result = ($mitigationsRule.MitigationTarget -split ',') -contains $rule.MitigationTarget
                        $result | Should Be $true
                    }
                }
                else
                {
                    It "Should return MitigationTarget '$($mitigationsRule.MitigationTarget)'" {
                        $rule.MitigationTarget | Should Be $mitigationsRule.MitigationTarget
                    }
                }

                It "Should return Enable $($mitigationsRule.Enable -join ',' )" {
                    $rule.Enable -split ',' | Should Be $($mitigationsRule.Enable -split ',')
                }
                It "Should return Disable '$($mitigationsRule.Disable -join ',')'" {
                    $rule.Disable | Should be $mitigationsRule.Disable
                }
                It 'Enable Should not return "Enable"' {
                    $rule.Enable -contains 'Enable' | Should Be $false
                }
                It 'Enable Should not return "ON"' {
                    $rule.Enable -contains 'ON' | Should Be $false
                }
                It 'Enable Should not return ":"' {
                    $rule.Enable -contains ':' | Should Be $false
                }
                It "Should set the correct DscResource" {
                    $rule.DscResource | Should Be 'ProcessMitigation'
                }
            }
        }
    }
    #endregion
}
finally
{
    . $PSScriptRoot\.tests.footer.ps1
}
