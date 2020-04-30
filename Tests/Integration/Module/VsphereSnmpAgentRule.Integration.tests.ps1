#region Header
. $PSScriptRoot\.tests.header.ps1
#endregion

$testCases = @(
    @{
        Enabled = '$false'
        CheckContent = 'From a PowerCLI command prompt while connected to the ESXi host run the following command:

        Get-VMHostSnmp | Select *

        or

        From a console or ssh session run the follow command:

        esxcli system snmp get

        If SNMP is not in use and is enabled, this is a finding.

        If SNMP is enabled and read only communities is set to public, this is a finding.

        If SNMP is enabled and is not using v3 targets, this is a finding.

        Note: SNMP v3 targets can only be viewed and configured from the esxcli command.'
        FixText = 'To disable SNMP run the following command from a PowerCLI command prompt while connected to the ESXi Host:

        Get-VMHostSnmp | Set-VMHostSnmp -Enabled $false

        or

        From a console or ssh session run the follow command:

        esxcli system snmp set -e no

        To configure SNMP for v3 targets use the "esxcli system snmp set" command set.'
    }
)

try
{
    Describe 'VsphereSnmpAgent Rule Conversion' {

        Context 'When VsphereSnmpAgent is converted' {

            It 'Should return a correctly converted "<Enabled>" Rule' -TestCases $testCases {
                param ($Enabled, $CheckContent, $FixText)

                [xml] $stigRule = Get-TestStigRule -Checkcontent $CheckContent -FixText $FixText -XccdfTitle 'Vsphere'
                $testFile = Join-Path -Path $TestDrive -ChildPath 'TextData.xml'
                $stigRule.Save($testFile)
                $rule = ConvertFrom-StigXccdf -Path $testFile

                $rule.GetType().Name   | Should -Be 'VsphereSnmpAgentRule'
                $rule.Enabled          | Should -Be $Enabled
                $rule.DscResource      | Should -Be 'VMHostSnmpAgent'
                $rule.ConversionStatus | Should -Be 'pass'
            }
        }
    }
}

finally
{
    . $PSScriptRoot\.tests.footer.ps1
}
