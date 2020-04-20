#region Header
. $PSScriptRoot\.tests.header.ps1
#endregion

try
{
    $stigRulesToTest = @(
        @{
            OrganizationValueTestString = '{0} is set to a string array of authoritative DoD time sources'
            CheckContent = 'From the vSphere Web Client select the ESXi Host and go to Configure >> System >> Time Configuration. Click Edit to verify the configured NTP servers and service startup policy.

            or

            From a PowerCLI command prompt while connected to the ESXi host run the following command:

            Get-VMHost | Get-VMHostNTPServer

            If the NTP service is not configured with authoritative DoD time sources and the service is not configured to start and stop with the host and is running, this is a finding.'
        }
    )

    Describe 'VsphereNtpSettings Rule Conversion' {

        foreach ( $stig in $stigRulesToTest )
        {
            Context "VsphereNtpSettings" {

                [xml] $StigRule = Get-TestStigRule -Checkcontent $stig.CheckContent -XccdfTitle 'Vsphere' -GroupId 'V-94039'
                $TestFile = Join-Path -Path $TestDrive -ChildPath 'TextData.xml'
                $StigRule.Save($TestFile)
                $rule = ConvertFrom-StigXccdf -Path $TestFile

                It 'Should return an VsphereNtpSettingsRule Object' {
                    $rule.GetType() | Should Be 'VsphereNtpSettingsRule'
                }
                It "Should return organizational test string '$($stig.OrganizationValueTestString)'" {
                    $rule.OrganizationValueTestString | Should Be $stig.OrganizationValueTestString
                }
                It 'Should set the correct DscResource' {
                    $rule.DscResource | Should Be 'VMHostNtpSettings'
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
