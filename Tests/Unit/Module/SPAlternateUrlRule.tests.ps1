#region Header
. $PSScriptRoot\.tests.header.ps1
#endregion

try
{
    InModuleScope -ModuleName "$($global:moduleName).Convert" {
        #region Test Setup
        $testRuleList = @(
            @{
                SPAlternateUrlItem = $null 
                DscResource     = 'SPAlternateUrl'
                CheckContent    = "Review the SharePoint server configuration to ensure the confidentiality of information during aggregation, packaging, and transformation in preparation for transmission is maintained.
    
                In SharePoint Central Administration, click Application Management.
                
                On the Application Management page, in the Web Applications list, click Manage web applications.
                
                On the Web Applications Management page, verify that each Web Application URL begins with https.
                
                If the URL does not begin with https, this is a finding.
                
                If SharePoint communications between all components and clients are protected by alternative physical measures that have been approved by the AO, this is not a finding."
            },
            @{
                SPAlternateUrlItem = $null 
                DscResource     = 'SPAlternateUrl'
                CheckContent    = "Review the SharePoint server to ensure cryptographic mechanisms preventing the unauthorized disclosure of information during transmission are employed, unless the transmitted data is otherwise protected by alternative physical measures.
    
                In SharePoint Central Administration, click Application Management.
                
                On the Application Management page, in the Web Applications list, click Manage web applications.
                
                On the Web Applications Management page, verify that each Web Application URL begins with https.
                
                If the URL does not begin with https, this is a finding.
                
                If SharePoint communications between all components and clients are protected by alternative physical measures that have been approved by the AO, this is not a finding."
            },
            @{
                SPAlternateUrlItem = $null 
                DscResource     = 'SPAlternateUrl'
                CheckContent    = 'Review the SharePoint server configuration to ensure approved cryptography is being utilized to protect the confidentiality of remote access sessions.
    
                Navigate to Central Administration.
                
                Under “System Settings”, click “Configure Alternate Access mappings”.
                
                Review the “Public URL for zone” column values. If any URL does not begin with “https”, this is a finding.'
            },
            @{
                SPAlternateUrlItem = $null
                DscResource     = 'SPAlternateUrl'
                CheckContent    = 'Review the SharePoint server configuration to ensure SSL Mutual authentication of both client and server during the entire session.
    
                Navigate to Central Administration.
                
                Under “System Settings”, click “Configure Alternate Access mappings”.
                
                Review the “Public URL for zone” column values. If any URL does not begin with “https”, this is a finding.'
            },
            @{
                SPAlternateUrlItem = $null # @{Url = "https://Other.contoso.com"; WebAppName = "Other web App"; Zone = "Default"; Internal = "$False"}
                DscResource     = 'SPAlternateUrl'
                CheckContent    = 'Review the SharePoint server configuration to ensure cryptography is being used to protect the integrity of the remote access session.
    
                Navigate to Central Administration.
                
                Under “System Settings”, click “Configure Alternate Access mappings”.
                
                Review the “Public URL for zone” column values. If any URL does not begin with “https”, this is a finding.'
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
