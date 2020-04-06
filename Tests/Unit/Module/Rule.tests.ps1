#region Header
. $PSScriptRoot\.tests.header.ps1
$setDynamicClassFileParams = @{
    ClassModuleFileName = 'Rule.psm1', 'ConvertFactory.psm1'
    PowerStigBuildPath  = $script:moduleRoot
    DestinationPath     = (Join-Path -Path $PSScriptRoot -ChildPath '..\.DynamicClassImport\Rule.ps1')
}
Set-DynamicClassFile @setDynamicClassFileParams
. $setDynamicClassFileParams.DestinationPath
#endregion
try
{
    InModuleScope -ModuleName $global:moduleName {
        #region Test Setup
        $stig = [Rule]::new( (Get-TestStigRule -ReturnGroupOnly), $true )
        $script:moduleRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot))
        #endregion
        #region Class Tests
        Describe "$($stig.GetType().Name) Base Class" {

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

            Context 'Methods' {

                $stigClassMethodNames = Get-StigBaseMethods

                foreach ( $method in $stigClassMethodNames )
                {
                    It "Should have a method named '$method'" {
                        ( $stig | Get-Member -Name $method -Force ).Name | Should Be $method
                    }
                }
            }

            Context 'Static Methods' {

                $staticMethods = @('SplitCheckContent', 'GetFixText')

                foreach ( $method in $staticMethods )
                {
                    It "Should have a method named '$method'" {
                        ( [Rule] | Get-Member -Static -Name $method -Force ).Name | Should Be $method
                    }
                }
                # If new methods are added this will catch them so test coverage can be added
                It 'Should not have more static methods than are tested' {
                    $memberPlanned = $staticMethods + @('Equals', 'new', 'ReferenceEquals')
                    $memberActual = ( [Rule] | Get-Member -Static -MemberType Method -Force ).Name
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
        #endregion
    }

    InModuleScope -ModuleName ConvertFactory {
        Describe 'Convert Factory' {
            Context 'AccountPolicyRule' {
                $checkContent = 'Run "gpedit.msc".

                Navigate to Local Computer Policy -&gt; Computer Configuration -&gt; Windows Settings -&gt; Security Settings -&gt; Account Policies -&gt; Account Lockout Policy.

                If the "Account lockout threshold" is "0" or more than "3" attempts, this is a finding.'

                It "Should return AccountPolicyRule when 'Account Policies' is found" {
                    $rule = Get-TestStigRule -CheckContent $checkContent -ReturnGroupOnly
                    $testResults = [ConvertFactory]::Rule( $rule )
                    $testResults[0].GetType().Name | Should Be 'AccountPolicyRule'
                }
            }

            Context 'AuditPolicyRule' {
                $checkContent = 'Security Option "Audit: Force audit policy subcategory settings (Windows Vista or later) to override audit policy category settings" must be set to "Enabled" (V-14230) for the detailed auditing subcategories to be effective.

                Use the AuditPol tool to review the current Audit Policy configuration:
                -Open a Command Prompt with elevated privileges ("Run as Administrator").
                -Enter "AuditPol /get /category:*".

                Compare the AuditPol settings with the following.  If the system does not audit the following, this is a finding.

                Account Management -&gt; Computer Account Management - Success'

                It "Should return 'AuditPolicyRule' when 'auditpol.exe' is found" {
                    $rule = Get-TestStigRule -CheckContent $checkContent -ReturnGroupOnly
                    $testResults = [ConvertFactory]::Rule( $rule )
                    $testResults[0].GetType().Name | Should Be 'AuditPolicyRule'
                }
                It "Should return 'ManualRule' when 'resourceSACL' is found" {
                    $rule = Get-TestStigRule -CheckContent ($checkContent + 'resourceSACL') -ReturnGroupOnly
                    $testResults = [ConvertFactory]::Rule( $rule )
                    $testResults[0].GetType().Name | Should Be 'ManualRule'
                }
                It "Should NOT return 'AuditPolicyRule' when 'SCENoApplyLegacyAuditPolicy' is found" {
                    $rule = Get-TestStigRule -CheckContent ($checkContent + 'SCENoApplyLegacyAuditPolicy') -ReturnGroupOnly
                    $testResults = [ConvertFactory]::Rule( $rule )
                    $testResults[0].GetType().Name| Should Not Be 'AccountPolicyRule'
                }
            }

            Context 'DnsServerSettingRule' {

                It "Should return 'DnsServerSettingRule' when only 'dnsmgmt.msc' is found" {
                    $rule = Get-TestStigRule -CheckContent 'dnsmgmt.msc' -ReturnGroupOnly
                    $testResults = [ConvertFactory]::Rule( $rule )
                    $testResults[0].GetType().Name | Should Be 'DnsServerSettingRule'
                }
                It "Should not return 'DnsServerSettingRule' when 'dnsmgmt.msc and 'Forward Lookup Zones is found" {
                    $rule = Get-TestStigRule -CheckContent 'dnsmgmt.msc and Forward Lookup Zones' -ReturnGroupOnly
                    $testResults = [ConvertFactory]::Rule( $rule )
                    $testResults[0].GetType().Name | Should Not Be 'DnsServerSettingRule'
                }
            }

            Context 'DocumentRule' {
                $checkContent = 'If no accounts are members of the Backup Operators group, this is NA.

                Any accounts that are members of the Backup Operators group, including application accounts, must be documented with the ISSO.  If documentation of accounts that are members of the Backup Operators group is not maintained this is a finding.'
                It "Should return 'DocumentRule' when 'Document' is found" {
                    $rule = Get-TestStigRule -CheckContent $checkContent -ReturnGroupOnly
                    $testResults = [ConvertFactory]::Rule( $rule )
                    $testResults[0].GetType().Name | Should Be 'DocumentRule'
                }
            }

            Context 'ManualRule' {
                It "Should return 'ManualRule' when nothing else is found" {
                    $checkContent = 'none of this matches'
                    $rule = Get-TestStigRule -CheckContent $checkContent -ReturnGroupOnly
                    $testResults = [ConvertFactory]::Rule( $rule )
                    $testResults[0].GetType().Name | Should Be 'ManualRule'
                }
            }

            Context 'PermissionRule' {
                It "Should return 'PermissionRule' when 'eventvwr.msc and Logs\Microsoft' is found" {
                    $checkContent = 'permissions'
                    $rule = Get-TestStigRule -CheckContent $checkContent -ReturnGroupOnly
                    $testResults = [ConvertFactory]::Rule( $rule )
                    $testResults[0].GetType().Name | Should Be 'PermissionRule'
                }
                It "Should Not return 'PermissionRule' when 'Verify the permissions on Group Policy objects' is found" {
                    $checkContent = 'Verify the permissions on Group Policy objects'
                    $rule = Get-TestStigRule -CheckContent $checkContent -ReturnGroupOnly
                    $testResults = [ConvertFactory]::Rule( $rule )
                    $testResults[0].GetType().Name | Should Not Be 'PermissionRule'
                }
                It "Should Not return 'PermissionRule' when 'Devices and Printers permissions' is found" {
                    $checkContent = 'Devices and Printers permissions'
                    $rule = Get-TestStigRule -CheckContent $checkContent -ReturnGroupOnly
                    $testResults = [ConvertFactory]::Rule( $rule )
                    $testResults[0].GetType().Name | Should Not Be 'PermissionRule'
                }
            }

            Context 'RegistryRule' {
                It "Should return 'RegistryRule' when 'HKEY_LOCAL_MACHINE' is found" {
                    $checkContent = 'Registry Hive: HKEY_LOCAL_MACHINE
                    Registry Path: \Software\Microsoft\Windows\CurrentVersion\Policies\System\

                    Value Name: ShutdownWithoutLogon

                    Value Type: REG_DWORD
                    Value: 0'
                    $rule = Get-TestStigRule -CheckContent $checkContent -ReturnGroupOnly
                    $testResults = [ConvertFactory]::Rule( $rule )
                    $testResults[0].GetType().Name | Should Be 'RegistryRule'
                }
                It "Should Not return 'RegistryRule' when 'Permission' is found" {
                    $checkContent = 'Hive: HKEY_LOCAL_MACHINE Permission'
                    $rule = Get-TestStigRule -CheckContent $checkContent -ReturnGroupOnly
                    $testResults = [ConvertFactory]::Rule( $rule )
                    $testResults[0].GetType().Name | Should Not Be 'RegistryRule'
                }
            }

            Context 'SecurityOptionRule' {
                $checkContent = 'Run "gpedit.msc".

                Navigate to Local Computer Policy -&gt; Computer Configuration -&gt; Windows Settings -&gt; Security Settings -&gt; Local Policies -&gt; Security Options.

                If the value for "Accounts: Guest account status" is not set to "Disabled", this is a finding.'
                It "Should return 'SecurityOptionRule' when 'gpedit and Security Option' is found" {
                    $rule = Get-TestStigRule -CheckContent $checkContent -ReturnGroupOnly
                    $testResults = [ConvertFactory]::Rule( $rule )
                    $testResults[0].GetType().Name | Should Be 'SecurityOptionRule'
                }
                It "Should Not return 'SecurityOptionRule' when 'gpedit and Account Policy' are found" {
                    $checkContent = 'gpedit and Account Policy'
                    $rule = Get-TestStigRule -CheckContent $checkContent -ReturnGroupOnly
                    $testResults = [ConvertFactory]::Rule( $rule )
                    $testResults[0].GetType().Name | Should Not Be 'SecurityOptionRule'
                }
                It "Should Not return 'SecurityOptionRule' when 'gpedit and User Rights Assignment' are found" {
                    $checkContent = 'gpedit and User Rights Assignment'
                    $rule = Get-TestStigRule -CheckContent $checkContent -ReturnGroupOnly
                    $testResults = [ConvertFactory]::Rule( $rule )
                    $testResults[0].GetType().Name | Should Not Be 'SecurityOptionRule'
                }
            }

            Context 'ServiceRule' {
                It "Should return 'ServiceRule' when 'services.msc' is found" {
                    $checkContent = 'services.msc'
                    $rule = Get-TestStigRule -CheckContent $checkContent -ReturnGroupOnly
                    $testResults = [ConvertFactory]::Rule( $rule )
                    $testResults[0].GetType().Name | Should Be 'ServiceRule'
                }
                It "Should Not return 'ServiceRule' when 'Required Services' is found" {
                    $checkContent = 'Required Services'
                    $rule = Get-TestStigRule -CheckContent $checkContent -ReturnGroupOnly
                    $testResults = [ConvertFactory]::Rule( $rule )
                    $testResults[0].GetType().Name | Should Not Be 'ServiceRule'
                }
                It "Should Not return 'ServiceRule' when 'presence of applications' is found" {
                    $checkContent = 'presence of applications'
                    $rule = Get-TestStigRule -CheckContent $checkContent -ReturnGroupOnly
                    $testResults = [ConvertFactory]::Rule( $rule )
                    $testResults[0].GetType().Name | Should Not Be 'ServiceRule'
                }
            }

            Context 'UserRightRule' {
                $checkContent = 'Run "gpedit.msc".

                Navigate to Local Computer Policy -&gt; Computer Configuration -&gt; Windows Settings -&gt; Security Settings -&gt; Local Policies -&gt; User Rights Assignment.

                If any accounts or groups (to include administrators), are granted the "Act as part of the operating system" user right, this is a finding.'
                It "Should return 'UserRightRule' when 'gpedit and Security Option' is found" {
                    $rule = Get-TestStigRule -CheckContent $checkContent -ReturnGroupOnly
                    $testResults = [ConvertFactory]::Rule( $rule )
                    $testResults[0].GetType().Name | Should Be 'UserRightRule'
                }
                It "Should Not return 'UserRightRule' when 'gpedit and Account Policy' are found" {
                    $checkContent = 'gpedit and Account Policy'
                    $rule = Get-TestStigRule -CheckContent $checkContent -ReturnGroupOnly
                    $testResults = [ConvertFactory]::Rule( $rule )
                    $testResults[0].GetType().Name | Should Not Be 'UserRightRule'
                }
                It "Should Not return 'UserRightRule' when 'gpedit and Security Option' are found" {
                    $checkContent = 'gpedit and Security Option'
                    $rule = Get-TestStigRule -CheckContent $checkContent -ReturnGroupOnly
                    $testResults = [ConvertFactory]::Rule( $rule )
                    $testResults[0].GetType().Name | Should Not Be 'UserRightRule'
                }
            }

            Context 'WindowsFeatureRule' {
                It "Should return 'WindowsFeatureRule' when 'Get-WindowsFeature' is found" {
                    $checkContent = 'Get-WindowsFeature'
                    $rule = Get-TestStigRule -CheckContent $checkContent -ReturnGroupOnly
                    $testResults = [ConvertFactory]::Rule( $rule )
                    $testResults[0].GetType().Name | Should Be 'WindowsFeatureRule'
                }
                It "Should return 'WindowsFeatureRule' when 'Get-WindowsOptionalFeature' is found" {
                    $checkContent = 'Get-WindowsOptionalFeature'
                    $rule = Get-TestStigRule -CheckContent $checkContent -ReturnGroupOnly
                    $testResults = [ConvertFactory]::Rule( $rule )
                    $testResults[0].GetType().Name | Should Be 'WindowsFeatureRule'
                }
            }

            Context 'WinEventLogRule' {
                It "Should return 'WinEventLogRule' when 'eventvwr.msc and Logs\Microsoft' is found" {
                    $checkContent = 'eventvwr.msc applications and Services Logs\Microsoft\Windows\DNS Server'
                    $rule = Get-TestStigRule -CheckContent $checkContent -ReturnGroupOnly
                    $testResults = [ConvertFactory]::Rule( $rule )
                    $testResults[0].GetType().Name | Should Be 'WinEventLogRule'
                }
                It "Should Not return 'WinEventLogRule' when only 'eventvwr.msc' is found" {
                    $checkContent = 'eventvwr.msc'
                    $rule = Get-TestStigRule -CheckContent $checkContent -ReturnGroupOnly
                    $testResults = [ConvertFactory]::Rule( $rule )
                    $testResults[0].GetType().Name | Should Not Be 'WinEventLogRule'
                }
                It "Should Not return 'WinEventLogRule' when only 'Logs\Microsoft' is found" {
                    $checkContent = 'Logs\Microsoft'
                    $rule = Get-TestStigRule -CheckContent $checkContent -ReturnGroupOnly
                    $testResults = [ConvertFactory]::Rule( $rule )
                    $testResults[0].GetType().Name | Should Not Be 'WinEventLogRule'
                }
            }
        }
    }
}
finally
{
    . $PSScriptRoot\.tests.footer.ps1
}
