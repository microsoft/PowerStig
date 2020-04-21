#region Header
. $PSScriptRoot\.tests.header.ps1
#endregion

try
{
    $stigRulesToTest = @(
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

    Describe 'VsphereSnmpAgent Rule Conversion' {

        foreach ( $stig in $stigRulesToTest )
        {
            Context "VsphereSnmpAgent '$($stig.Enabled)'" {

                [xml] $StigRule = Get-TestStigRule -Checkcontent $stig.CheckContent -FixText $stig.FixText -XccdfTitle 'Vsphere'
                $TestFile = Join-Path -Path $TestDrive -ChildPath 'TextData.xml'
                $StigRule.Save($TestFile)
                $rule = ConvertFrom-StigXccdf -Path $TestFile

                It 'Should return an VsphereSnmpAgentRule Object' {
                    $rule.GetType() | Should Be 'VsphereSnmpAgentRule'
                }
                It "Should return Key '$($stig.Enabled)'" {
                    $rule.Enabled | Should Be $stig.Enabled
                }
                It 'Should set the correct DscResource' {
                    $rule.DscResource | Should Be 'VMHostSnmpAgent'
                }
                It 'Should Set the status to pass' {
                    $rule.ConversionStatus | Should Be 'pass'
                }
            }
        }
    }
}

finally
{
    . $PSScriptRoot\.tests.footer.ps1
}
