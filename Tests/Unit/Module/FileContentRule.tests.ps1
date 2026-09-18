#region Header
. $PSScriptRoot\.tests.header.ps1
#endregion

try
{
    InModuleScope -ModuleName "$($global:moduleName).Convert" {
        #region Test Setup
        $testRuleList = @(
            @{
                Key                       = 'security.default_personal_cert'
                Value                     = 'Ask Every Time'
                ArchiveFile               = 'MozillaFirefox'
                DscResource               = 'ReplaceText'
                OrganizationValueRequired = $false
                CheckContent              = 'Type "about:config" in the browser address bar. Verify  Preference Name "security.default_personal_cert" is set to "Ask Every Time" and is locked to prevent the user from altering.

                Criteria: If the value of "security.default_personal_cert" is set incorrectly or is not locked, then this is a finding.'
                FilePath                  = $null
            },
            @{
                Key                       = 'plugin.disable_full_page_plugin_for_types'
                Value                     = 'PDF,FDF,XFDF,LSL,LSO,LSS,IQY,RQY,XLK,XLS,XLT,POT,PPS,PPT,DOS,DOT,WKS,BAT,PS,EPS,WCH,WCM,WB1,WB3,RTF,DOC,MDB,MDE,WBK,WB1,WCH,WCM,AD,ADP'
                ArchiveFile               = 'MozillaFirefox'
                OrganizationValueRequired = $false
                CheckContent              = 'Open a browser window, type "about:config" in the address bar.

                Criteria:  If the "plugin.disable_full_page_plugin_for_types" value is not set to include the following external extensions and not locked, then this is a finding:

                PDF, FDF, XFDF, LSL, LSO, LSS, IQY, RQY, XLK, XLS, XLT, POT PPS, PPT, DOS, DOT, WKS, BAT, PS, EPS, WCH, WCM, WB1, WB3, RTF, DOC, MDB, MDE, WBK, WB1, WCH, WCM, AD, ADP.'
                FilePath                  = $null
            },
            @{
                Key                       = 'PermitEmptyPasswords'
                Value                     = 'no'
                FilePath                  = '%ProgramData%\ssh\sshd_config'
                ArchiveFile               = 'WindowsServer'
                DscResource               = 'Script'
                OrganizationValueRequired = $false
                CheckContent              = 'If OpenSSH is not installed on the system, this requirement is not applicable.

                Get-Content "$env:ProgramData\ssh\sshd_config" | Select-String -Pattern ''^\s*PermitEmptyPasswords''

                PermitEmptyPasswords no

                If the "PermitEmptyPasswords" keyword is set to "yes", is missing, or is commented out, this is a finding.'
            },
            @{
                Key                       = 'Banner'
                Value                     = '%ProgramData%\ssh\Banner.txt'
                FilePath                  = '%ProgramData%\ssh\sshd_config'
                ArchiveFile               = 'WindowsServer'
                DscResource               = 'Script'
                OrganizationValueRequired = $false
                CheckContent              = 'If OpenSSH is not installed on the system, this requirement is not applicable.

                Get-Content "$env:ProgramData\ssh\sshd_config" | Select-String -Pattern ''^\s*Banner''

                Banner C:\ProgramData\ssh\Banner.txt

                If "Banner" is set to "none", the line is commented out, or the line is missing, this is a finding.'
            },
            @{
                Key                       = 'DisableTelemetry'
                Value                     = '{"DisableTelemetry":true}'
                FilePath                  = 'distribution\policies.json'
                ArchiveFile               = 'MozillaFirefox'
                DscResource               = 'Script'
                OrganizationValueRequired = $false
                CheckContent              = 'Type "about:policies" in the browser window. If "DisableTelemetry" is not displayed under Policy Name or the Policy Value is not "true", this is a finding.'
                FixText                   = 'Linux "policies.json" file: Add the following in the policies section: "DisableTelemetry": true'
            },
            @{
                Key                       = 'Preferences'
                Value                     = '{"Preferences":{"dom.disable_window_flip":{"Value":true,"Status":"locked"}}}'
                FilePath                  = 'distribution\policies.json'
                ArchiveFile               = 'MozillaFirefox'
                DscResource               = 'Script'
                OrganizationValueRequired = $false
                CheckContent              = 'Type "about:policies" in the browser address bar. If "Preferences" does not include "dom.disable_window_flip" with a value of "true" and status of "locked", this is a finding.'
                FixText                   = 'Linux "policies.json" file: Add the following in the policies section: "Preferences": { "dom.disable_window_flip": { "Value": true, "Status": "locked" } }'
            },
            @{
                Key                       = 'Certificates'
                Value                     = '{"Certificates":{"ImportEnterpriseRoots":true}}'
                FilePath                  = 'distribution\policies.json'
                ArchiveFile               = 'MozillaFirefox'
                DscResource               = 'Script'
                OrganizationValueRequired = $false
                CheckContent              = 'This can be set via the policy Certificates >> ImportEnterpriseRoots, which can be verified via "about:policies".'
                FixText                   = 'On Windows, import certificates from the operating system by using Certificates >> Import Enterprise Roots via policy.'
            }
            # TODO Add common test logic to support the multiple and split test data
            #,
            #
        )
        #endregion

        foreach ($testRule in $testRuleList)
        {
            $global:stigXccdfName = $testRule.ArchiveFile
            # The ArchiveFile is a control flag and not a property of the class.
            $testRule.Remove('ArchiveFile')
            . $PSScriptRoot\Convert.CommonTests.ps1
        }

        #region Add Custom Tests Here
        Describe 'MultipleRules' {
            # TODO move this to the CommonTests
            $testRuleList = @(
                @{
                    ArchiveFile  = 'OracleJRE'
                    Count        = 2
                    CheckContent = 'If the system is on the SIPRNet, this requirement is NA.

                        Navigate to the system-level "deployment.properties" file for JRE.

                        The location of the deployment.properties file is defined in &gt;JRE Installation Directory&lt;\Lib\deployment.config

                        If the key "deployment.security.revocation.check=ALL_CERTIFICATES" is not present, or is set to "PUBLISHER_ONLY", or "NO_CHECK", this is a finding.

                        If the key "deployment.security.revocation.check.locked" is not present, this is a finding.'
                }
                @{
                    ArchiveFile  = 'MozillaFirefox'
                    Count        = 5
                    CheckContent = 'Open a browser window, type "about:config" in the address bar.

                        Verify Preference Name "security.enable_tls" is set to the value "true" and locked.
                        Verify Preference Name "security.enable_ssl2" is set to the value "false" and locked.
                        Verify Preference Name "security.enable_ssl3" is set to the value "false" and locked.
                        Verify Preference Name "security.tls.version.min" is set to the value "2" and locked.
                        Verify Preference Name "security.tls.version.max" is set to the value "3" and locked.

                        Criteria: If the parameters are set incorrectly, then this is a finding.

                        If the settings are not locked, then this is a finding.'
                }
            )
            foreach ($testRule in $testRuleList)
            {
                $global:stigXccdfName = $testRule.ArchiveFile

                It "Should return $true" {
                    $multipleRule = [FileContentRuleConvert]::HasMultipleRules($testRule.CheckContent)
                    $multipleRule | Should -Be $true
                }
                It "Should return $($testRule.Count) rules" {
                    $multipleRule = [FileContentRuleConvert]::SplitMultipleRules($testRule.CheckContent)
                    $multipleRule.count | Should -Be $testRule.Count
                }
            }
        }
        # #endregion
    }
}
finally
{
    . $PSScriptRoot\.tests.footer.ps1
}
