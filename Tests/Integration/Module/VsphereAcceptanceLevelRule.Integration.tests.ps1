#region Header
. $PSScriptRoot\.tests.header.ps1
#endregion

$testCases = @(
    @{
        Level = 'PartnerSupported'
        CheckContent = 'From the vSphere Web Client select the ESXi Host and go to Configure >> System >> Security Profile. Under "Host Image Profile Acceptance Level" view the acceptance level.

        or

        From a PowerCLI command prompt while connected to the ESXi host run the following commands:

        $esxcli = Get-EsxCli
        $esxcli.software.acceptance.get()

        If the acceptance level is CommunitySupported, this is a finding.'
        FixText  = 'From the vSphere Web Client select the ESXi Host and go to Configure >> System >> Security Profile. Under "Host Image Profile Acceptance Level" click Edit… and use the pull-down selection, set the acceptance level to be VMwareCertified, VMwareAccepted, or PartnerSupported.

        or

        From a PowerCLI command prompt while connected to the ESXi host run the following commands:

        $esxcli = Get-EsxCli
        $esxcli.software.acceptance.Set("PartnerSupported")

        Note: VMwareCertified or VMwareAccepted may be substituted for PartnerSupported, depending upon local requirements.'
    }
)

try
{
    Describe 'VsphereAcceptanceLevel Rule Conversion' {

        Context "When VsphereAcceptanceLevel is converted" {

            It 'Should return a correctly converted "<Level>" Rule' -TestCases $testCases {
                param ($Level, $CheckContent, $FixText)

                [xml] $stigRule = Get-TestStigRule -CheckContent $CheckContent -FixText $FixText -XccdfTitle 'Vsphere'
                $testFile = Join-Path -Path $TestDrive -ChildPath 'TextData.xml'
                $stigRule.Save($testFile)
                $rule = ConvertFrom-StigXccdf -Path $testFile

                $rule.GetType().Name   | Should -Be 'VsphereAcceptanceLevelRule'
                $rule.Level            | Should -Be $Level
                $rule.DscResource      | Should -Be 'VMHostAcceptanceLevel'
                $rule.ConversionStatus | Should -Be 'pass'
            }
        }
    }
}

finally
{
    . $PSScriptRoot\.tests.footer.ps1
}
