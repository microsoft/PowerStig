#region Header
. $PSScriptRoot\.tests.header.ps1
#

try
{
    $mitigationsRulesToTest = @(
        @{
            MitigationTarget = 'System'
            MitigationType   = 'Heap'
            MitigationName   = 'TerminateOnError'
            MitigationValue  = 'true'
            CheckContent     = ' This is NA prior to v1709 of Windows 10.

            Run "Windows PowerShell" with elevated privileges (run as administrator).

            Enter "Get-ProcessMitigation -System".

            If the status of "Heap: TerminateOnError" is "OFF", this is a finding.

            Values that would not be a finding include:
            ON
            NOTSET'
        }
    )

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

                It "Should return MitigationTarget '$($mitigationsRule.MitigationTarget)'" {
                    $rule.MitigationTarget | Should Be $mitigationsRule.MitigationTarget
                }

                It "Should return MitigationType '$($mitigationsRule.MitigationType)'" {
                    $rule.MitigationType | Should be $mitigationsRule.MitigationType
                }

                It "Should return MitigationName '$($mitigationsRule.MitigationName)'" {
                    $rule.MitigationName | Should be $mitigationsRule.MitigationName
                }

                It "Should return MitigationValue '$($mitigationsRule.MitigationValue)'" {
                    $rule.MitigationValue | Should be $mitigationsRule.MitigationValue
                }

                It "Should set the correct DscResource" {
                    $rule.DscResource | Should Be 'ProcessMitigation'
                }
            }
        }
    }
}

finally
{
    . $PSScriptRoot\.tests.footer.ps1
}
