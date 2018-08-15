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
            CheckContent = 'Type "about:config" in the browser address bar. Verify  Preference Name "security.default_personal_cert" is set to "Ask Every Time" and is locked to prevent the user from altering.

            Criteria: If the value of "security.default_personal_cert" is set incorrectly or is not locked, then this is a finding.'
        }
        @{
            Key          = 'plugin.disable_full_page_plugin_for_types'
            Value        = 'PDF,FDF,XFDF,LSL,LSO,LSS,IQY,RQY,XLK,XLS,XLT,POT,PPS,PPT,DOS,DOT,WKS,BAT,PS,EPS,WCH,WCM,WB1,WB3,RTF,DOC,MDB,MDE,WBK,WB1,WCH,WCM,AD,ADP'
            CheckContent = 'Open a browser window, type "about:config" in the address bar.

            Criteria:  If the "plugin.disable_full_page_plugin_for_types" value is not set to include the following external extensions and not locked, then this is a finding:

            PDF, FDF, XFDF, LSL, LSO, LSS, IQY, RQY, XLK, XLS, XLT, POT PPS, PPT, DOS, DOT, WKS, BAT, PS, EPS, WCH, WCM, WB1, WB3, RTF, DOC, MDB, MDE, WBK, WB1, WCH, WCM, AD, ADP.'
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
            $rule = ConvertFrom-StigXccdf -Path $TestFile

            It 'Should be a FileContentRule' {
                $rule.GetType().Name -eq 'FileContentRule' | Should Be $true
            }

            It "Should return Key:'$($rule.Key)'" {
                $rule.Key | Should Be $fileContentRule.Key
            }

            It "Should return Value:'$($rule.Value)'" {
                $rule.Value | Should Be $fileContentRule.Value
            }
        }
    }
    #endregion
}
finally
{
    . $PSScriptRoot\.tests.footer.ps1
}
