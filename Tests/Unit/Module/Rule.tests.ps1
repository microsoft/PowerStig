#region Header
using module .\..\..\..\Module\Rule\Rule.psm1
. $PSScriptRoot\.tests.header.ps1
#endregion
try
{
    InModuleScope -ModuleName $script:moduleName {
        #region Test Setup
        $stig = [Rule]::new()
        $stig.InvokeClass( (Get-TestStigRule -ReturnGroupOnly) )
        #endregion
        #region Class Tests
        Describe "$($stig.GetType().Name) Base Class" {

            $type = $stig.GetType()

            It "Should be of BaseType '$($type.BaseType)'" {
                $type.BaseType.ToString() | Should Be 'System.Object'
            }

            Context 'InvokeClass with Stigdata element' {

                It 'Should return the rule Id' {
                    $stig.id | Should Be 'V-1000'
                }
                It 'Should return the Severity' {
                    $stig.severity | Should Be 'medium'
                }
                It 'Should return the Title' {
                    $stig.title | Should Be 'Sample Title'
                }
                It 'Should return the default status of pass' {
                    $stig.conversionstatus | Should Be 'pass'
                }
                It 'Should return the raw string' {
                    $stig.rawString | Should Not BeNullOrEmpty
                }
                It 'Should return decoded html in the rawString' {
                    $stig.rawString | Should Not Match '&\w+;'
                }
                It 'Should set IsNullOrEmptyt to false by default' {
                    $stig.IsNullOrEmpty | Should Be $false
                }
                It 'Should set OrganizationValueRequired to false by default' {
                    $stig.OrganizationValueRequired | Should Be $false
                }
                It 'Should OrganizationValueTestString to empty by default' {
                    $stig.OrganizationValueTestString | Should BeNullOrEmpty
                }
            }

            Context 'Methods' {

                $stigClassMethodNames = Get-StigBaseMethods

                foreach ( $method in $stigClassMethodNames )
                {
                    It "Should have a method named '$method'" {
                        ( $stig | Get-Member -Name $method ).Name | Should Be $method
                    }
                }
                # If new methods are added this will catch them so test coverage can be added
                It 'Should not have more methods than are tested' {
                    $memberPlanned = $stigClassMethodNames
                    $memberActual = ( $stig | Get-Member -MemberType Method ).Name
                    $compare = Compare-Object -ReferenceObject $memberActual -DifferenceObject $memberPlanned
                    $compare.Count | Should Be 0
                }
            }

            Context 'Static Methods' {

                $staticMethods = @('SplitCheckContent', 'GetRuleTypeMatchList', 'GetFixText')

                foreach ( $method in $staticMethods )
                {
                    It "Should have a method named '$method'" {
                        ( [Rule] | Get-Member -Static -Name $method ).Name | Should Be $method
                    }
                }
                # If new methods are added this will catch them so test coverage can be added
                It 'Should not have more static methods than are tested' {
                    $memberPlanned = $staticMethods + @('Equals', 'new', 'ReferenceEquals')
                    $memberActual = ( [Rule] | Get-Member -Static -MemberType Method ).Name
                    $compare = Compare-Object -ReferenceObject $memberActual -DifferenceObject $memberPlanned
                    $compare.Count | Should Be 0
                }
            }
        }
        #endregion
        #region Method Tests
        Describe 'SplitCheckContent static method' {
            # This creates a multiline string with a blank line between them
            $checkContent = '
            Line 1

            Line 2
            '

            [string[]] $splitCheckContent = [Rule]::SplitCheckContent( $checkContent )

            It 'Should trim strings and remove empty lines' {
                $splitCheckContent[0] | Should Be 'Line 1'
                $splitCheckContent[1] | Should Be 'Line 2'
                $splitCheckContent[2] | Should BeNullOrEmpty
            }
        }

        Describe 'Encoding functions' {

            $encodedString = 'Local Computer Policy -&gt;-&gt; Computer Configuration -&gt;-&gt; '
            $decodedString = 'Local Computer Policy ->-> Computer Configuration ->-> '

            Context 'Test-HtmlEncoding' {

                It 'Should return true when encoded characters are found' {
                    Test-HtmlEncoding -CheckString $encodedString  | Should Be $true
                }
                It 'Should return false when encoded characters are found' {
                    Test-HtmlEncoding -CheckString $decodedString  | Should Be $false
                }
            }

            Context 'Test-HtmlEncoding' {

                It 'Should decode html encoding' {
                    ConvertFrom-HtmlEncoding -CheckString $encodedString | Should Be $decodedString
                }
            }
        }

        Describe 'Get-RuleTypeMatchList' {

            Context 'AccountPolicyRule' {
                $checkContent = 'Run "gpedit.msc".

                Navigate to Local Computer Policy -&gt; Computer Configuration -&gt; Windows Settings -&gt; Security Settings -&gt; Account Policies -&gt; Account Lockout Policy.

                If the "Account lockout threshold" is "0" or more than "3" attempts, this is a finding.'
                It 'Should return AccountPolicyRule when 'Account Policies' is found' {
                    $testResults = Get-RuleTypeMatchList -CheckContent $checkContent
                    $testResults | Should Be 'AccountPolicyRule'
                }
            }

            Context 'AccountPolicyRule' {
                $checkContent = 'Security Option "Audit: Force audit policy subcategory settings (Windows Vista or later) to override audit policy category settings" must be set to "Enabled" (V-14230) for the detailed auditing subcategories to be effective.

                Use the AuditPol tool to review the current Audit Policy configuration:
                -Open a Command Prompt with elevated privileges ("Run as Administrator").
                -Enter "AuditPol /get /category:*".

                Compare the AuditPol settings with the following.  If the system does not audit the following, this is a finding.

                Account Management -&gt; Computer Account Management - Success'
                It "Should return 'AuditPolicyRule' when 'auditpol.exe' is found" {
                    $testResults = Get-RuleTypeMatchList -CheckContent $checkContent
                    $testResults | Should Be 'AuditPolicyRule'
                }
                It "Should return 'ManualRule' when 'resourceSACL' is found" {
                    $testResults = Get-RuleTypeMatchList -CheckContent ($checkContent + 'resourceSACL')
                    $testResults | Should Be 'ManualRule'
                }
                It "Should NOT return 'AuditPolicyRule' when 'SCENoApplyLegacyAuditPolicy' is found" {
                    $testResults = Get-RuleTypeMatchList -CheckContent ($checkContent + 'SCENoApplyLegacyAuditPolicy')
                    $testResults | Should Not Be 'AccountPolicyRule'
                }
            }

            Context 'DnsServerSettingRule' {

                It "Should return 'DnsServerSettingRule' when only 'dnsmgmt.msc' is found" {
                    $testResults = Get-RuleTypeMatchList -CheckContent 'dnsmgmt.msc'
                    $testResults | Should Be 'DnsServerSettingRule'
                }
                It "Should not return 'DnsServerSettingRule' when 'dnsmgmt.msc and 'Forward Lookup Zones is found" {
                    $testResults = Get-RuleTypeMatchList -CheckContent 'dnsmgmt.msc and Forward Lookup Zones'
                    $testResults | Should Not Be 'DnsServerSettingRule'
                }
            }

            Context 'DocumentRule' {
                $checkContent = 'If no accounts are members of the Backup Operators group, this is NA.

                Any accounts that are members of the Backup Operators group, including application accounts, must be documented with the ISSO.  If documentation of accounts that are members of the Backup Operators group is not maintained this is a finding.'
                It "Should return 'DocumentRule' when 'Document' is found" {
                    $testResults = Get-RuleTypeMatchList -CheckContent $checkContent
                    $testResults | Should Be 'DocumentRule'
                }
            }

            Context 'ManualRule' {
                It "Should return 'ManualRule' when nothing else is found" {
                    $testResults = Get-RuleTypeMatchList -CheckContent 'none of this matches'
                    $testResults | Should Be 'ManualRule'
                }
            }

            Context 'PermissionRule' {
                It "Should return 'PermissionRule' when 'eventvwr.msc and Logs\Microsoft' is found" {
                    $testResults = Get-RuleTypeMatchList -CheckContent 'permissions'
                    $testResults | Should Be 'PermissionRule'
                }
                It "Should Not return 'PermissionRule' when 'Verify the permissions on Group Policy objects' is found" {
                    $testResults = Get-RuleTypeMatchList -CheckContent 'Verify the permissions on Group Policy objects'
                    $testResults | Should Not Be 'PermissionRule'
                }
                It "Should Not return 'PermissionRule' when 'Devices and Printers permissions' is found" {
                    $testResults = Get-RuleTypeMatchList -CheckContent 'Devices and Printers permissions'
                    $testResults | Should Not Be 'PermissionRule'
                }
            }

            Context 'RegistryRule' {
                It "Should return 'RegistryRule' when 'HKEY_LOCAL_MACHINE' is found" {
                    $testResults = Get-RuleTypeMatchList -CheckContent 'HKEY_LOCAL_MACHINE'
                    $testResults | Should Be 'RegistryRule'
                }
                It "Should Not return 'RegistryRule' when 'Permission' is found" {
                    $testResults = Get-RuleTypeMatchList -CheckContent 'HKEY_LOCAL_MACHINE Permission'
                    $testResults | Should Not Be 'RegistryRule'
                }
                It "Should Not return 'RegistryRule' when 'SupportedEncryptionTypes' is found" {
                    $testResults = Get-RuleTypeMatchList -CheckContent 'HKEY_LOCAL_MACHINE SupportedEncryptionTypes'
                    $testResults | Should Not Be 'RegistryRule'
                }
            }

            Context 'SecurityOptionRule' {
                $checkContent = 'Run "gpedit.msc".

                Navigate to Local Computer Policy -&gt; Computer Configuration -&gt; Windows Settings -&gt; Security Settings -&gt; Local Policies -&gt; Security Options.

                If the value for "Accounts: Guest account status" is not set to "Disabled", this is a finding.'
                It "Should return 'SecurityOptionRule' when 'gpedit and Security Option' is found" {
                    $testResults = Get-RuleTypeMatchList -CheckContent $checkContent
                    $testResults | Should Be 'SecurityOptionRule'
                }
                It "Should Not return 'SecurityOptionRule' when 'gpedit and Account Policy' are found" {
                    $testResults = Get-RuleTypeMatchList -CheckContent 'gpedit and Account Policy'
                    $testResults | Should Not Be 'SecurityOptionRule'
                }
                It "Should Not return 'SecurityOptionRule' when 'gpedit and User Rights Assignment' are found" {
                    $testResults = Get-RuleTypeMatchList -CheckContent 'gpedit and User Rights Assignment'
                    $testResults | Should Not Be 'SecurityOptionRule'
                }
            }

            Context 'ServiceRule' {
                It "Should return 'ServiceRule' when 'services.msc' is found" {
                    $testResults = Get-RuleTypeMatchList -CheckContent 'services.msc'
                    $testResults | Should Be 'ServiceRule'
                }
                It "Should Not return 'ServiceRule' when 'Required Services' is found" {
                    $testResults = Get-RuleTypeMatchList -CheckContent 'Required Services'
                    $testResults | Should Not Be 'ServiceRule'
                }
                It "Should Not return 'ServiceRule' when 'presence of applications' is found" {
                    $testResults = Get-RuleTypeMatchList -CheckContent 'presence of applications'
                    $testResults | Should Not Be 'ServiceRule'
                }
            }

            Context 'UserRightRule' {
                $checkContent = 'Run "gpedit.msc".

                Navigate to Local Computer Policy -&gt; Computer Configuration -&gt; Windows Settings -&gt; Security Settings -&gt; Local Policies -&gt; User Rights Assignment.

                If any accounts or groups (to include administrators), are granted the "Act as part of the operating system" user right, this is a finding.'
                It "Should return 'UserRightRule' when 'gpedit and Security Option' is found" {
                    $testResults = Get-RuleTypeMatchList -CheckContent $checkContent
                    $testResults | Should Be 'UserRightRule'
                }
                It "Should Not return 'UserRightRule' when 'gpedit and Account Policy' are found" {
                    $testResults = Get-RuleTypeMatchList -CheckContent 'gpedit and Account Policy'
                    $testResults | Should Not Be 'UserRightRule'
                }
                It "Should Not return 'UserRightRule' when 'gpedit and Security Option' are found" {
                    $testResults = Get-RuleTypeMatchList -CheckContent 'gpedit and Security Option'
                    $testResults | Should Not Be 'UserRightRule'
                }
            }

            Context 'WindowsFeatureRule' {
                It "Should return 'WindowsFeatureRule' when 'Get-WindowsFeature' is found" {
                    $testResults = Get-RuleTypeMatchList -CheckContent 'Get-WindowsFeature'
                    $testResults | Should Be 'WindowsFeatureRule'
                }
                It "Should return 'WindowsFeatureRule' when 'Get-WindowsOptionalFeature' is found" {
                    $testResults = Get-RuleTypeMatchList -CheckContent 'Get-WindowsOptionalFeature'
                    $testResults | Should Be 'WindowsFeatureRule'
                }
            }

            Context 'WmiRule' {
                It "Should return 'WmiRule' when 'Disk Management' is found" {
                    $testResults = Get-RuleTypeMatchList -CheckContent 'Disk Management'
                    $testResults | Should Be 'WmiRule'
                }
                It "Should return 'WmiRule' when 'Service Pack' is found" {
                    $testResults = Get-RuleTypeMatchList -CheckContent 'Service Pack'
                    $testResults | Should Be 'WmiRule'
                }
            }

            Context 'WinEventLogRule' {
                It "Should return 'WinEventLogRule' when 'eventvwr.msc and Logs\Microsoft' is found" {
                    $testResults = Get-RuleTypeMatchList -CheckContent 'eventvwr.msc applications and Services Logs\Microsoft\Windows\DNS Server'
                    $testResults | Should Be 'WinEventLogRule'
                }
                It "Should Not return 'WinEventLogRule' when only 'eventvwr.msc' is found" {
                    $testResults = Get-RuleTypeMatchList -CheckContent 'eventvwr.msc'
                    $testResults | Should Not Be 'WinEventLogRule'
                }
                It "Should Not return 'WinEventLogRule' when only 'Logs\Microsoft' is found" {
                    $testResults = Get-RuleTypeMatchList -CheckContent 'Logs\Microsoft'
                    $testResults | Should Not Be 'WinEventLogRule'
                }
            }
        }
        #endregion
        #region Function Tests

        #endregion
        #region Data Tests

        #endregion
    }
}
finally
{
    . $PSScriptRoot\.tests.footer.ps1
}
