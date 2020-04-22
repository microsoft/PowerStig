#region Header
. $PSScriptRoot\.tests.header.ps1
#endregion

try
{
    $stigRulesToTest = @(
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

    Describe 'VsphereAcceptanceLevel Rule Conversion' {

        foreach ($stig in $stigRulesToTest)
        {
            Context "VsphereAcceptanceLevel '$($stig.Level)'" {

                [xml] $stigRule = Get-TestStigRule -Checkcontent $stig.CheckContent -FixText $stig.FixText -XccdfTitle 'Vsphere'
                $testFile = Join-Path -Path $TestDrive -ChildPath 'TextData.xml'
                $stigRule.Save($testFile)
                $rule = ConvertFrom-StigXccdf -Path $testFile

                It 'Should return an VsphereAcceptanceLevelRule Object' {
                    $rule.GetType() | Should Be 'VsphereAcceptanceLevelRule'
                }

                It "Should return Value '$($stig.Level)'" {
                    $rule.Level | Should Be $stig.Level
                }

                It 'Should set the correct DscResource' {
                    $rule.DscResource | Should Be 'VMHostAcceptanceLevel'
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
