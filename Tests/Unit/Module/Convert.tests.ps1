#region Header
using module .\..\..\..\Module\Convert\Convert.psm1
. $PSScriptRoot\.tests.header.ps1
#endregion

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
        It "Should Not return 'RegistryRule' when 'SupportedEncryptionTypes' is found" {
            $checkContent = 'Registry Hive:  HKEY_LOCAL_MACHINE
            Registry Path:  \SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Kerberos\Parameters\
            Value Name:  SupportedEncryptionTypes
            Type:  REG_DWORD'
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

    Context 'WmiRule' {
        It "Should return 'WmiRule' when 'Disk Management' is found" {
            $checkContent = 'Disk Management'
            $rule = Get-TestStigRule -CheckContent $checkContent -ReturnGroupOnly
            $testResults = [ConvertFactory]::Rule( $rule )
            $testResults[0].GetType().Name | Should Be 'WmiRule'
        }
        It "Should return 'WmiRule' when 'Service Pack' is found" {
            $checkContent = 'Service Pack If the "About Windows" dialog box does not display
            "Microsoft Windows Server
            Version 6.2 (Build 9200)"
            or greater, this is a finding. '
            $rule = Get-TestStigRule -CheckContent $checkContent -ReturnGroupOnly
            $testResults = [ConvertFactory]::Rule( $rule )
            $testResults[0].GetType().Name | Should Be 'WmiRule'
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
