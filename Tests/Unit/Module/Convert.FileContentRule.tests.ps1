#region Header
using module .\..\..\..\Module\Convert.FileContentRule\Convert.FileContentRule.psm1
. $PSScriptRoot\.tests.header.ps1
#endregion
try
{
    InModuleScope -ModuleName $script:moduleName {
        #region Test Setup
        $rulesToTest = @(
            @{
                Key          = 'Security.*'
                Value        = 'MultipleRule'
                ArchiveFile  = 'MozillaFirefox'
                CheckContent = 'Open a browser window, type "about:config" in the address bar.

                Verify Preference Name "security.enable_tls" is set to the value "true" and locked.
                Verify Preference Name "security.enable_ssl2" is set to the value "false" and locked.
                Verify Preference Name "security.enable_ssl3" is set to the value "false" and locked.
                Verify Preference Name "security.tls.version.min" is set to the value "2" and locked.
                Verify Preference Name "security.tls.version.max" is set to the value "3" and locked.

                Criteria: If the parameters are set incorrectly, then this is a finding. 

                If the settings are not locked, then this is a finding.'
            }
            @{
                Key          = 'security.default_personal_cert'
                Value        = 'Ask Every Time'
                ArchiveFile  = 'MozillaFirefox'
                CheckContent = 'Type "about:config" in the browser address bar. Verify  Preference Name "security.default_personal_cert" is set to "Ask Every Time" and is locked to prevent the user from altering.

                Criteria: If the value of "security.default_personal_cert" is set incorrectly or is not locked, then this is a finding.'
            }
            @{
                Key          = 'plugin.disable_full_page_plugin_for_types'
                Value        = 'PDF,FDF,XFDF,LSL,LSO,LSS,IQY,RQY,XLK,XLS,XLT,POT,PPS,PPT,DOS,DOT,WKS,BAT,PS,EPS,WCH,WCM,WB1,WB3,RTF,DOC,MDB,MDE,WBK,WB1,WCH,WCM,AD,ADP'
                ArchiveFile  = 'MozillaFirefox'
                CheckContent = 'Open a browser window, type "about:config" in the address bar.

                Criteria:  If the "plugin.disable_full_page_plugin_for_types" value is not set to include the following external extensions and not locked, then this is a finding:

                PDF, FDF, XFDF, LSL, LSO, LSS, IQY, RQY, XLK, XLS, XLT, POT PPS, PPT, DOS, DOT, WKS, BAT, PS, EPS, WCH, WCM, WB1, WB3, RTF, DOC, MDB, MDE, WBK, WB1, WCH, WCM, AD, ADP.'
            }
            @{
                Key          = 'deployment.security.revocation.check*'
                Value        = 'MultipleRule'
                ArchiveFile  = 'OracleJRE'
                CheckContent = 'If the system is on the SIPRNet, this requirement is NA. 
                
                Navigate to the system-level "deployment.properties" file for JRE. 
                
                The location of the deployment.properties file is defined in <JRE Installation Directory>\Lib\deployment.config 
                
                If the key "deployment.security.revocation.check=ALL_CERTIFICATES" is not present, or is set to "PUBLISHER_ONLY", or "NO_CHECK", this is a finding. 
                
                If the key "deployment.security.revocation.check.locked" is not present, this is a finding.'
            }
       )
       $rule = [FileContentRule]::new( (Get-TestStigRule -ReturnGroupOnly) )
        #endregion
        #region Class Tests
        Describe "$($rule.GetType().Name) Child Class" {

            Context 'Base Class' {

                It "Shoud have a BaseType of STIG" {
                    $rule.GetType().BaseType.ToString() | Should Be 'STIG'
                }
            }

            Context 'Class Properties' {

                $classProperties = @('Key', 'Value')

                foreach ( $property in $classProperties )
                {
                    It "Should have a property named '$property'" {
                        ( $rule | Get-Member -Name $property ).Name | Should Be $property
                    }
                }
            }

            Context 'Class Methods' {

                $classMethods = @('SetKeyName', 'SetValue')

                foreach ( $method in $classMethods )
                {
                    It "Should have a method named '$method'" {
                        ( $rule | Get-Member -Name $method ).Name | Should Be $method
                    }
                }

                # If new methods are added this will catch them so test coverage can be added
                It "Should not have more methods than are tested" {
                    $memberPlanned = Get-StigBaseMethods -ChildClassMethodNames $classMethods
                    $memberActual = ( $rule | Get-Member -MemberType Method ).Name
                    $compare = Compare-Object -ReferenceObject $memberActual -DifferenceObject $memberPlanned
                    $compare.Count | Should Be 0
                }
            }
        }
        #endregion
        #region Method Tests
        Describe 'Get-KeyValuePair' {
            foreach ( $rule in $rulesToTest )
            {
                $global:stigArchiveFile = $rule.ArchiveFile
                if ($rule.Value -ne 'MultipleRule')
                {
                    It "Should be a Key of '$($rule.Key)'" {
                        $checkContent = Split-TestStrings -CheckContent $rule.CheckContent
                        $result = Get-KeyValuePair -CheckContent $checkContent
                        $result.Key | Should Be $rule.Key
                    }

                    It "Should be a Value of '$($rule.Value)'" {
                        $checkContent = Split-TestStrings -CheckContent $rule.CheckContent
                        $result = Get-KeyValuePair -CheckContent $checkContent
                        $result.Value | Should Be $rule.Value
                    }
                }
            }
        }

        Describe 'Test-MultipleFileContentRule' {
            foreach ( $rule in $rulesToTest )
            {
                if ($rule.Value -eq 'MultipleRule')
                {
                    $checkContent = Split-TestStrings -CheckContent $rule.CheckContent
                    $keyValuePairs = Get-KeyValuePair -CheckContent $checkContent
                    $result = Test-MultipleFileContentRule -KeyValuePair $checkContent
                    
                    <# 'Enable' property of $rule is missing casuing empty string output #>
                    It "Should have Enable equal to: '$($rule.Enable)'" {

                        $result | Should Be $true
                    }
                }
            }
        }
        #endregion
        #region Function Tests
        Describe "ConvertTo-FileContentRule" {

            $global:stigArchiveFile = $rulesToTest[1].ArchiveFile
            $stigRule = Get-TestStigRule -CheckContent $rulesToTest[1].checkContent -ReturnGroupOnly
            $rule = ConvertTo-FileContentRule -StigRule $stigRule

            It "Should return a FileContentRule object" {
                $rule.GetType() | Should Be 'FileContentRule'
            }
        }
        #endregion
        #region Data Tests

        #endregion
    }
}
finally
{
    . $PSScriptRoot\.tests.footer.ps1
}
