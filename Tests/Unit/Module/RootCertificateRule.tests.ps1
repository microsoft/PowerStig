#region Header
. $PSScriptRoot\.tests.header.ps1
#endregion

try
{
    InModuleScope -ModuleName "$($global:moduleName).Convert" {
        #region Test Setup
        $testRuleList = @(
            @{
                CertificateName = "US DoD CCEB Interoperability Root CA 2"
                Thumbprint = "929BF3196896994C0A201DF4A5B71F603FEFBF2E"
                OrganizationValueRequired = $true
                OrganizationValueTestString = "location for US DoD CCEB Interoperability Root CA 2 certificate is present"
                CheckContent = 'Verify the US DoD CCEB Interoperability Root CA cross-certificate is installed on unclassified systems as an Untrusted Certificate.

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
        #endregion

        foreach ($testRule in $testRuleList)
        {
            . $PSScriptRoot\Convert.CommonTests.ps1
        }
    }
}
finally
{
    . $PSScriptRoot\.tests.footer.ps1
}
