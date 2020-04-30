#region Header
. $PSScriptRoot\.tests.header.ps1
#endregion

$testCases = @(
    @{
        OrganizationValueTestString = '{0} is set to a string array of authoritative DoD time sources'
        CheckContent = 'From the vSphere Web Client select the ESXi Host and go to Configure >> System >> Time Configuration. Click Edit to verify the configured NTP servers and service startup policy.

        or

        From a PowerCLI command prompt while connected to the ESXi host run the following command:

        Get-VMHost | Get-VMHostNTPServer

        If the NTP service is not configured with authoritative DoD time sources and the service is not configured to start and stop with the host and is running, this is a finding.'
    }
)

try
{
    Describe 'VsphereNtpSettings Rule Conversion' {

        Context 'When VsphereNtpSettings is converted' {

            It 'Should return a correctly converted "<OrganizationValueTestString>" Rule' -TestCases $testCases {
                param ($OrganizationValueTestString, $CheckContent)

                [xml] $stigRule = Get-TestStigRule -Checkcontent $CheckContent -XccdfTitle 'Vsphere' -GroupId 'V-94039'
                $testFile = Join-Path -Path $TestDrive -ChildPath 'TextData.xml'
                $stigRule.Save($testFile)
                $rule = ConvertFrom-StigXccdf -Path $testFile

                $rule.GetType().Name              | Should -Be 'VsphereNtpSettingsRule'
                $rule.OrganizationValueTestString | Should -Be $OrganizationValueTestString
                $rule.DscResource                 | Should -Be 'VMHostNtpSettings'
                $rule.ConversionStatus            | Should -Be 'pass'
            }
        }
    }
}

finally
{
    . $PSScriptRoot\.tests.footer.ps1
}
