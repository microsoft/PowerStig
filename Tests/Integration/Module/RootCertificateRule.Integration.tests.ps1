#region Header
. $PSScriptRoot\.tests.header.ps1
#endregion

try
{
    $stigRulesToTest = @(
        @{
            CertificateName = 'US DoD CCEB Interoperability Root CA 2'
            Thumbprint      = '929BF3196896994C0A201DF4A5B71F603FEFBF2E'
            CheckContent    = 'Verify the US DoD CCEB Interoperability Root CA cross-certificate is installed on unclassified systems as an Untrusted Certificate.

            Run "PowerShell" as an administrator.
            
            Execute the following command:
            
            Get-ChildItem -Path Cert:Localmachine\disallowed | Where Issuer -Like "*CCEB Interoperability*" | FL Subject, Issuer, Thumbprint, NotAfter
            
            If the following certificate "Subject", "Issuer", and "Thumbprint", information is not displayed, this is finding.
            
            If an expired certificate ("NotAfter" date) is not listed in the results, this is not a finding.
            
            Subject: CN=DoD Root CA 3, OU=PKI, OU=DoD, O=U.S. Government, C=US
            Issuer: CN=US DoD CCEB Interoperability Root CA 2, OU=PKI, OU=DoD, O=U.S. Government, C=US
            Thumbprint: 929BF3196896994C0A201DF4A5B71F603FEFBF2E
            NotAfter: 9/27/2019
            
            Alternately use the Certificates MMC snap-in:
            
            Run "MMC".
            
            Select "File", "Add/Remove Snap-in".
            
            Select "Certificates", click "Add".
            
            Select "Computer account", click "Next".
            
            Select "Local computer: (the computer this console is running on)", click "Finish".
            
            Click "OK".
            
            Expand "Certificates" and navigate to "Untrusted Certificates &gt;&gt; Certificates".
            
            For each certificate with "US DoD CCEB Interoperability Root CA …" under "Issued By":
            
            Right-click on the certificate and select "Open".
            
            Select the "Details" Tab.
            
            Scroll to the bottom and select "Thumbprint".
            
            If the certificate below is not listed or the value for the "Thumbprint" field is not as noted, this is a finding.
            
            If an expired certificate ("Valid to" date) is not listed in the results, this is not a finding.
            
            Issued To: DoD Root CA 3
            Issuer by: US DoD CCEB Interoperability Root CA 2
            Thumbprint: 929BF3196896994C0A201DF4A5B71F603FEFBF2E
            Valid: Friday, September 27, 2019'
        }
    )

    Describe 'RootCertificate Rule Conversion' {

        foreach ($stig in $stigRulesToTest)
        {
            [xml] $stigRule = Get-TestStigRule -CheckContent $stig.CheckContent -XccdfTitle 'IIS'
            $TestFile = Join-Path -Path $TestDrive -ChildPath 'TextData.xml'
            $stigRule.Save( $TestFile )
            $rule = ConvertFrom-StigXccdf -Path $TestFile

            It 'Should return an RootCertificateRule  Object' {
                $rule.GetType() | Should Be 'RootCertificateRule'
            }
            It "Should return Thumbprint '$($stig.Thumbprint)'" {
                $rule.Thumbprint | Should Be $stig.Thumbprint
            }
            It "Should return Certificate Name '$($stig.CertificateName)'" {
                $rule.CertificateName| Should Be $stig.CertificateName
            }
            It "Should set the correct DscResource" {
                $rule.DscResource | Should Be 'CertificateDSC'
            }
            It 'Should Set the status to pass' {
                $rule.ConversionStatus | Should Be 'pass'
            }
        }
    }
}

finally
{
    . $PSScriptRoot\.tests.footer.ps1
}
