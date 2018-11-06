#region Header
using module .\..\..\..\Module\MimeTypeRule\MimeTypeRule.psm1
. $PSScriptRoot\.tests.header.ps1
#endregion
try
{
    InModuleScope -ModuleName $script:moduleName {
        #region Test Setup
        $mimeTypeRule = @{
            Ensure       = 'absent'
            Extension    = '.exe'
            RuleCount    = 5
            CheckContent = 'Follow the procedures below for each site hosted on the IIS 8.5 web server:

                Open the IIS 8.5 Manager.

                Click on the IIS 8.5 site.

                Under IIS, double-click the MIME Types icon.

                From the "Group by:" drop-down list, select "Content Type".

                From the list of extensions under "Application", verify MIME types for OS shell program extensions have been removed, to include at a minimum, the following extensions:

                .exe

                If any OS shell MIME types are configured, this is a finding.'
        }

        $multipleMimeTypeRule = @{
            RuleCount = 5
            CheckContent = 'Follow the procedures below for each site hosted on the IIS 8.5 web server:

                Open the IIS 8.5 Manager.

                Click on the IIS 8.5 site.

                Under IIS, double-click the MIME Types icon.

                From the "Group by:" drop-down list, select "Content Type".

                From the list of extensions under "Application", verify MIME types for OS shell program extensions have been removed, to include at a minimum, the following extensions:

                .exe
                .dll
                .com
                .bat
                .csh

                If any OS shell MIME types are configured, this is a finding.'
        }

        $mimeTypeMapping = @{
            '.exe' = 'application/octet-stream'
            '.dll' = 'application/x-msdownload'
            '.bat' = 'application/x-bat'
            '.csh' = 'application/x-csh'
            '.com' = 'application/octet-stream'
        }

        $stigRule = Get-TestStigRule -CheckContent $mimeTypeRule.CheckContent -ReturnGroupOnly
        $rule = [MimeTypeRule]::new( $stigRule )
        #endregion
        #region Class Tests
        Describe "$($rule.GetType().Name) Child Class"{

            Context 'Base Class'{

                It 'Shoud have a BaseType of STIG' {
                    $rule.GetType().BaseType.ToString() | Should Be 'Rule'
                }
            }

            Context 'Class Properties'{

                $classProperties = @('Ensure', 'Extension', 'MimeType')

                foreach ( $property in $classProperties )
                {
                    It "Should have a property named '$property'"{
                        ( $rule | Get-Member -Name $property ).Name | Should Be $property
                    }
                }
            }
        }
        #endregion
        #region Method Tests
        Describe 'Get-Extension'{
            It "Should return $($mimeTypeRule.Extension)" {
                $checkContent = Split-TestStrings -CheckContent $mimeTypeRule.CheckContent
                Get-Extension -CheckContent $checkContent | Should Be $mimeTypeRule.Extension
            }
        }

        Describe 'Get-MimeType'{
            foreach ($mimeType in $mimeTypeMapping.GetEnumerator())
            {
                It "Should return $($mimeType.value)"{
                    $mimeTypeResult = Get-MimeType -Extension $mimeType.key
                    $mimeTypeResult | Should Be $mimeType.value
                }
            }
        }

        Describe 'Get-Ensure'{
            It "Should return $($mimeTypeRule.Ensure)" {
                $checkContent = Split-TestStrings -CheckContent $mimeTypeRule.CheckContent
                Get-Ensure -CheckContent $checkContent | Should Be $mimeTypeRule.Ensure
            }
        }

        Describe 'Test-MultipleMimeTypeRule'{
            It "Should return $true"{
                $checkContent = Split-TestStrings -CheckContent $multipleMimeTypeRule.CheckContent
                Test-MultipleMimeTypeRule -CheckContent $checkContent | Should Be $true
            }
        }

        Describe 'Split-MultipleMimeTypeRule'{
            It "Should return $($multipleMimeTypeRule.RuleCount) rules" {
                $checkContent = Split-TestStrings -CheckContent $multipleMimeTypeRule.CheckContent
                $multipleRule = Split-MultipleMimeTypeRule -CheckContent $checkContent
                $multipleRule.count | Should Be $multipleMimeTypeRule.RuleCount
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
