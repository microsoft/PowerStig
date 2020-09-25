#region Header
. $PSScriptRoot\.tests.header.ps1
#endregion

try
{
    InModuleScope -ModuleName "$($global:moduleName).Convert" {
        #region Test Setup
        $testRuleList = @(
            @{
                CipherSuitesOrder = $null
                DscResource     = 'CipherSuites'
                OrganizationValueRequired = $true
                OrganizationValueTestString = "'{0}' 'must be an array of cipher suites that are not DES or RC4'"
                CheckContent    = 'Review the SharePoint server configuration to ensure mechanisms are used for authentication to a cryptographic module that meet the requirements of applicable federal laws, Executive Orders, directives, policies, regulations, standards, and guidance for such authentication.
    
                Open MMC.
                
                Click "File", "Add/Remove Snap-in", and "add Group Policy Object Editor".
                
                Enter a name for the Group Policy Object, or accept the default.
                
                Click "Finish".
                
                Click "OK".
                
                Navigate to Computer Policy >> Computer Configuration >> Administrative Templates >> Network >> SSL Configuration settings.
                
                Right-click "SSL Configuration Settings", click "SSL Cipher Suite Orde"r, click "Edit".
                
                In the "SSL Cipher Suite Order" dialog box, if "Enabled" is not selected, this is a finding.
                
                Under Options, in the "SSL Cipher Suites" text box, a list of cipher suites will be displayed.
                
                If any DES or RC4 cipher suites exist in the list, this is a finding.'
            },
            @{
                CipherSuitesOrder = $null
                DscResource     = 'CipherSuites'
                OrganizationValueRequired = $true
                OrganizationValueTestString = "'{0}' 'must be an array of cipher suites that are not DES or RC4'"
                CheckContent    = 'Review the SharePoint server configuration to ensure FIPS-validated cryptography is employed to protect unclassified information.
    
                Open MMC.
                
                Click "File", "Add/Remove Snap-in", and "add Group Policy Object Editor".
                
                Enter a name for the Group Policy Object, or accept the default.
                
                Click "Finish".
                
                Click "OK".
                
                Navigate to Computer Policy >> Computer Configuration >> Administrative Templates >> Network >> SSL Configuration settings
                
                Right-click "SSL Configuration Settings", click "SSL Cipher Suite Order", click "Edit".
                
                In the "SSL Cipher Suite Order" dialog box, if "Enabled" is not selected, this is a finding.
                
                Under Options, in the "SSL Cipher Suites" text box, a list of cipher suites will be displayed.
                
                If any DES or RC4 cipher suites exist in the list, this is a finding.'
            },
            @{
                CipherSuitesOrder = $null
                DscResource     = 'CipherSuites'
                OrganizationValueRequired = $true
                OrganizationValueTestString = "'{0}' 'must be an array of cipher suites that are not DES or RC4'"
                CheckContent    = 'Review the SharePoint server configuration to ensure FIPS-validated cryptography is employed to protect unclassified information when such information must be separated from individuals who have the necessary clearances yet lack the necessary access approvals.
    
                Open MMC.
                
                Click "File", "Add/Remove Snap-in", and "add Group Policy Object Editor".
                
                Enter a name for the Group Policy Object, or accept the default.
                
                Click "Finish".
                
                Click "OK".
                
                Navigate to Computer Policy >> Computer Configuration >> Administrative Templates >> Network >> SSL Configuration settings.
                
                Right-click "SSL Configuration Settings", click "SSL Cipher Suite Order", click "Edit".
                
                In the "SSL Cipher Suite Order" dialog box, if "Enabled" is not selected, this is a finding.
                
                Under Options, in the "SSL Cipher Suites" text box, a list of cipher suites will be displayed.
                
                If any DES or RC4 cipher suites exist in the list, this is a finding.'
            },
            @{
                CipherSuitesOrder = $null
                DscResource     = 'CipherSuites'
                OrganizationValueRequired = $true
                OrganizationValueTestString = "'{0}' 'must be an array of cipher suites that are not DES or RC4'"
                CheckContent    = 'Review the SharePoint server configuration to ensure required cryptographic protections using cryptographic modules complying with applicable federal laws, Executive Orders, directives, policies, regulations, standards, and guidance are implemented.
    
                Open MMC.
                
                Click "File", "Add/Remove Snap-in", and "add Group Policy Object Editor".
                
                Enter a name for the Group Policy Object, or accept the default.
                
                Click "Finish".
                
                Click "OK".
                
                Navigate to Computer Policy >> Computer Configuration >> Administrative Templates >> Network >> SSL Configuration settings.
                
                Right-click "SSL Configuration Settings", click "SSL Cipher Suite Order", click "Edit".
                
                In the "SSL Cipher Suite Order" dialog box, if "Enabled" is not selected, this is a finding.
                
                Under Options, in the "SSL Cipher Suites" text box, a list of cipher suites will be displayed.
                
                If any DES or RC4 cipher suites exist in the list, this is a finding.'
            },
            @{
                CipherSuitesOrder = $null
                DscResource     = 'CipherSuites'
                OrganizationValueRequired = $true
                OrganizationValueTestString = "'{0}' 'must be an array of cipher suites that are not DES or RC4'"
                CheckContent    = 'Review the SharePoint server configuration to ensure NSA-approved cryptography is employed to protect classified information.
    
                Open MMC.
                
                Click "File", "Add/Remove Snap-in", and "add Group Policy Object Editor".
                
                Enter a name for the Group Policy Object, or accept the default.
                
                Click "Finish".
                
                Click "OK".
                
                Navigate to Computer Policy >> Computer Configuration >> Administrative Templates >> Network >> SSL Configuration settings.
                
                Right-click "SSL Configuration Settings", click "SSL Cipher Suite Order", click "Edit".
                
                In the "SSL Cipher Suite Order" dialog box, if "Enabled" is not selected, this is a finding.
                
                Under Options, in the "SSL Cipher Suites" text box, a list of cipher suites will be displayed.
                
                If any DES or RC4 cipher suites exist in the list, this is a finding.'
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
