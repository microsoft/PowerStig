#region Header
using module .\..\..\..\Module\ProcessMitigationRule\ProcessMitigationRule.psm1
. $PSScriptRoot\.tests.header.ps1
#endregion
try
{
    InModuleScope -ModuleName $script:moduleName {
        #region Test Setup
        $rulesToTest = @(
            @{
                MitigationTarget = 'System'
                Enable           = 'TerminateOnError'
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
                Enable           = 'DEP,EnableExportAddressFilter,EnableExportAddressFilterPlus,EnableImportAddressFilter,EnableRopStackPivot,EnableRopCallerCheck,EnableRopSimExec'
                CheckContent     = 'This is NA prior to v1709 of Windows 10.

                Run "Windows PowerShell" with elevated privileges (run as administrator).

                Enter "Get-ProcessMitigation -Name wordpad.exe".
                (Get-ProcessMitigation can be run without the -Name parameter to get a list of all application mitigations configured.)

                If the following mitigations do not have a status of "ON", this is a finding:

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
            @{
                MitigationTarget = 'System'
                Enable           = 'DEP'
                CheckContent     = 'This is NA prior to v1709 of Windows 10.

                Run "Windows PowerShell" with elevated privileges (run as administrator).

                Enter "Get-ProcessMitigation -System".

                If the status of "DEP: Enable" is "OFF", this is a finding.

                Values that would not be a finding include:
                ON
                NOTSET'
            }
        )

        $stigRule = Get-TestStigRule -CheckContent $rulesToTest[0].CheckContent -ReturnGroupOnly
        $rule = [ProcessMitigationRule]::new( $stigRule )
        #endregion
        #region Class Tests
        Describe "$($rule.GetType().Name) Child Class" {

            Context 'Base Class' {

                It 'Shoud have a BaseType of STIG' {
                    $rule.GetType().BaseType.ToString() | Should Be 'Rule'
                }
            }

            Context 'Class Properties' {

                $classProperties = @('MitigationTarget', 'Enable', 'Disable')

                foreach ( $property in $classProperties )
                {
                    It "Should have a property named '$property'" {
                        ( $rule | Get-Member -Name $property ).Name | Should Be $property
                    }
                }
            }
        }
        #endregion
        #region Method Tests
        Describe 'Get-MitigationTargetName' {
            foreach ( $rule in $rulesToTest )
            {
                It "Should be a MitigationTarget of '$($rule.MitigationTarget)'" {
                    $checkContent = Split-TestStrings -CheckContent $rule.CheckContent
                    $result = Get-MitigationTargetName -CheckContent $checkContent
                    $result | Should Be $rule.MitigationTarget
                }
            }
        }

        Describe 'Get-MitigationPolicyToEnable' {
            Mock -CommandName Test-PoliciesToEnable -MockWith {$true}

            foreach ( $rule in $rulesToTest )
            {
                $checkContent = Split-TestStrings -CheckContent $rule.CheckContent
                $result = Get-MitigationPolicyToEnable -CheckContent $checkContent
                It "Should have Enable equal to: '$($rule.Enable)'" {

                    $result | Should Be $rule.Enable
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
