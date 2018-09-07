#region Header
. $PSScriptRoot\.tests.header.ps1
#endregion
try
{
    #region Test Setup
    $fileContentRulesToTest = @(
        @{
            Key          = 'security.default_personal_cert'
            Value        = 'Ask Every Time'
            DscResource  = 'ReplaceText'
            ArchiveFile  = 'MozillaFirefox'
            CheckContent = 'Type "about:config" in the browser address bar. Verify  Preference Name "security.default_personal_cert" is set to "Ask Every Time" and is locked to prevent the user from altering.

            Criteria: If the value of "security.default_personal_cert" is set incorrectly or is not locked, then this is a finding.'
        }
        @{
            Key          = 'plugin.disable_full_page_plugin_for_types'
            Value        = 'PDF,FDF,XFDF,LSL,LSO,LSS,IQY,RQY,XLK,XLS,XLT,POT,PPS,PPT,DOS,DOT,WKS,BAT,PS,EPS,WCH,WCM,WB1,WB3,RTF,DOC,MDB,MDE,WBK,WB1,WCH,WCM,AD,ADP'
            DscResource  = 'ReplaceText'
            ArchiveFile  = 'MozillaFirefox'
            CheckContent = 'Open a browser window, type "about:config" in the address bar.

            Criteria:  If the "plugin.disable_full_page_plugin_for_types" value is not set to include the following external extensions and not locked, then this is a finding:

            PDF, FDF, XFDF, LSL, LSO, LSS, IQY, RQY, XLK, XLS, XLT, POT PPS, PPT, DOS, DOT, WKS, BAT, PS, EPS, WCH, WCM, WB1, WB3, RTF, DOC, MDB, MDE, WBK, WB1, WCH, WCM, AD, ADP.'
        }
        @{
            Key          = 'app.update.enabled'
            Value        = 'false'
            DscResource  = 'cJsonFile'
            ArchiveFile  = 'MozillaFirefox'
            CheckContent = 'Type "about:config" in the browser window. Verify that

            1. The preference name "app.update.enabled" is set to "false" and locked or

            2. If set to "true" then verify that "app.update.url", "app.update.url.details" and "app.update.url.manual" contain url information that point to a trusted server and is not the default setting. (Default would contain mozilla.com or Mozilla.org). 


            Criteria: If the parameter is set incorrectly, then this is a finding. If this setting is not locked, then this is a finding.'
        }
        @{
            Key          = 'deployment.security.revocation.check'
            Value        = 'ALL_CERTIFICATES'
            DscResource  = 'KeyValuePairFile'
            ArchiveFile  = 'OracleJRE'
            CheckContent = 'If the system is on the SIPRNet, this requirement is NA.

            Navigate to the system-level "deployment.properties" file for JRE. 

            If the key "deployment.security.revocation.check=ALL_CERTIFICATES" is not present, or is set to "PUBLISHER_ONLY", or "NO_CHECK", this is a finding.'
        }
    )
    #endregion
    #region Tests
    Describe "FileContentRule Integration Tests" {
        foreach ($fileContentRule in $fileContentRulesToTest)
        {
            [xml] $StigRule = Get-TestStigRule -CheckContent $fileContentRule.CheckContent -XccdfTitle Windows
            $TestFile = Join-Path -Path $TestDrive -ChildPath 'TextData.xml'
            $StigRule.Save( $TestFile )
            $global:stigXccdfName = $fileContentRule.ArchiveFile
            $rule = ConvertFrom-StigXccdf -Path $TestFile

            It 'Should be a FileContentRule' {
                $rule.GetType() | Should Be 'FileContentRule'
            }

            It "Should return Key:'$($fileContentRule.Key)'" {
                $rule.Key | Should Be $fileContentRule.Key
            }

            It "Should return Value:'$($fileContentRule.Value)'" {
                $rule.Value | Should Be $fileContentRule.Value
            }

            It "Should have a DscResource of '$($fileContentRule.DscResource)'" {
                $rule.DscResource | Should Be $fileContentRule.DscResource
            }
        }
    }
    #endregion
}
finally
{
    . $PSScriptRoot\.tests.footer.ps1
}
