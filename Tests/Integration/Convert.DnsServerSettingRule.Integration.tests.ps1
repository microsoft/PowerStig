#region Header
. $PSScriptRoot\.tests.header.ps1
#endregion
try
{
    #region Test Setup
$forwardersCheckContent = @'
Note: If the Windows DNS server is in the classified network, this check is Not Applicable.

Note: In Windows 2008 DNS Server, if forwarders are configured, the recursion setting must also be enabled since disabling recursion will disable
forwarders.

If forwarders are not used, recursion must be disabled.

In both cases, the use of root hints must be disabled. The root hints configuration requirement is addressed in WDNS-CM-000004.

Log on to the DNS server using the Domain Admin or Enterprise Admin account.

Press Windows Key + R, execute dnsmgmt.msc.

On the opened DNS Manager snap-in from the left pane, right-click on the server name for the DNS server and select Propertiesâ€.

Click on the Forwarders tab.

If forwarders are enabled and configured, this check is not applicable.

If forwarders are not enabled, click on the Advanced tab and ensure the "Disable recursion (also disables forwarders)" check box is selected.

If forwarders are not enabled and configured, and the "Disable recursion (also disables forwarders)" check box in the Advanced tab is not
selected, this is a finding.
'@

$eventLogLevelCheckContent = @'
Log on to the DNS server using the Domain Admin or Enterprise Admin account.

Press Windows Key + R, execute dnsmgmt.msc.

Right-click the DNS server, select â€œPropertiesâ€.

Click on the â€œEvent Loggingâ€ tab. By default, all events are logged.

Verify "Errors and warnings" or "All events" is selected.

If any option other than "Errors and warnings" or "All events" is selected, this is a finding.
'@

$multiUserRightRule = @'
Review the DNS server to confirm the server restricts direct and remote console access to users other than Administrators.

Verify the effective setting in Local Group Policy Editor.

Run "gpedit.msc".

Navigate to Local Computer Policy >> Computer Configuration >> Windows Settings >> Security Settings >> Local Policies >> User Rights Assignment.

If any accounts or groups other than the following are granted the "Allow log on through Remote Desktop Services" user right, this is a finding:

Administrators

Navigate to Local Computer Policy >> Computer Configuration >> Windows Settings >> Security Settings >> Local Policies >> User Rights Assignment.

If the following accounts or groups are not defined for the "Deny access to this computer from the network" user right, this is a finding:

Guests Group

Navigate to Local Computer Policy >> Computer Configuration >> Windows Settings >> Security Settings >> Local Policies >> User Rights Assignment.

If the following accounts or groups are not defined for the "Deny log on locally" user right, this is a finding:

Guests Group
'@

$userRightPermissionRuleCombo = @'
Verify the effective setting in Local Group Policy Editor.

Run "gpedit.msc".

Navigate to Local Computer Policy >> Computer Configuration >> Windows Settings >>
Security Settings >> Local Policies >> User Rights Assignment.

If any accounts or groups other than the following are granted the "Manage auditing and security log" user right, this is a finding:

Administrators Auditors (if the site has an Auditors group that further limits this
privilege.)

Verify the permissions on the DNS logs.

Standard user accounts or groups must not have greater than READ access.

The default locations are:

DNS Server %SystemRoot%\System32\Winevt\Logs\DNS Server.evtx

Using the file explorer tool navigate to the DNS Server log file.

Right click on the log file, select the â€œSecurityâ€ tab.

The default permissions listed below satisfy this requirement:

Eventlog - Full Control
SYSTEM - Full Control
Administrators - Full Control

If the permissions for these files are not as restrictive as the ACLs listed, this is a
finding.
'@
    #endregion
    #region Tests
    Describe "DnsServerSettingRule conversion" {

        Context "Forwarders" {
            [xml] $StigRule = Get-TestStigRule -CheckContent $forwardersCheckContent -XccdfTitle 'Domain Name System'
            $TestFile = Join-Path -Path $TestDrive -ChildPath 'TextData.xml'
            $StigRule.Save( $TestFile )
            $rule = ConvertFrom-StigXccdf -Path $TestFile

            It "Should be a DnsServerSettingRule" {
                $rule.GetType() | Should be 'DnsServerSettingRule'
            }
            It "Should have Forwarders for PropertyName" {
                $rule.PropertyName | Should Be 'NoRecursion'
            }
            It "Should have PropertyValue of None" {
                $rule.PropertyValue | Should Be '$True'
            }
            It "Should set the correct DscResource" {
                $rule.DscResource | Should Be 'xDnsServerSetting'
            }
            It "Should set the Conversion status to pass" {
                $rule.conversionstatus | Should be 'pass'
            }
        }

        Context "EventLogLevel" {

            [xml] $StigRule = Get-TestStigRule -CheckContent $eventLogLevelCheckContent -XccdfTitle 'Domain Name System'
            $TestFile = Join-Path -Path $TestDrive -ChildPath 'TextData.xml'
            $StigRule.Save( $TestFile )
            $rule = ConvertFrom-StigXccdf -Path $TestFile

            It "Should be a DnsServerSettingRule" {
                $rule.GetType() | Should be 'DnsServerSettingRule'
            }
            It "Should have Forwarders for EventLogLevel" {
                $rule.PropertyName | Should Be 'EventLogLevel'
            }
            It "Should have PropertyValue of 4" {
                $rule.PropertyValue | Should Be '4'
            }
            It "Should set the correct DscResource" {
                $rule.DscResource | Should Be 'xDnsServerSetting'
            }
            It "Should set the Conversion status to pass" {
                $rule.conversionstatus | Should be 'pass'
            }
        }
    }

    Describe "UserRightRule conversion" {

        Context "Multiple settings in STIG rule" {

            [xml] $StigRule = Get-TestStigRule -CheckContent $multiUserRightRule -XccdfTitle 'Domain Name System'
            $TestFile = Join-Path -Path $TestDrive -ChildPath 'TextData.xml'
            $StigRule.Save( $TestFile )
            $rule = ConvertFrom-StigXccdf -Path $TestFile

            It "Should have 3 unique IDs" {
                $result = $rule | Select-Object Id -Unique
                $result.count | Should be 3
            }
        }

        Context "UserRightRule and PermissionRule Combo" {

            [xml] $StigRule = Get-TestStigRule -CheckContent $userRightPermissionRuleCombo -XccdfTitle 'Domain Name System'
            $TestFile = Join-Path -Path $TestDrive -ChildPath 'TextData.xml'
            $StigRule.Save( $TestFile )
            $rule = ConvertFrom-StigXccdf -Path $TestFile

            $userRightRule  = $rule | Where-Object { $PSItem.GetType().ToString() -eq 'UserRightRule' }
            $permissionRule = $rule | Where-Object { $PSItem.GetType().ToString() -eq 'PermissionRule' }

            It "Should contain a UserRightRule" {
                $userRightRule.GetType() | Should Be 'UserRightRule'
            }

            It "Should contain a PermissionRule" {
                $permissionRule.GetType() | Should Be 'PermissionRule'
            }

            It "Should have different Ids" {
                $result = $rule | Select-Object -Property Id -Unique
                $result.count | Should Be 2
            }

            It "PermissionRule should have correct property values" {
                $permissionRule.path | Should Be '%windir%\SYSTEM32\WINEVT\LOGS\DNS Server.evtx'

                foreach ($entry in $permissionRule.AccessControlEntry)
                {
                    $entry.Rights | Should Be 'FullControl'
                }

                $principalCount = $permissionRule.AccessControlEntry.Principal |
                    Where-Object {$PSItem -match 'Eventlog|SYSTEM|Administrators'}

                $principalCount.count | Should Be 3
            }

            It "UserRightRule Should have a correct property values" {
                $userRightRule.Constant | Should Be 'SeSecurityPrivilege'
                $userRightRule.Identity | Should Be 'Administrators'
            }
        }
    }
    #endregion
}
finally
{
    . $PSScriptRoot\.tests.footer.ps1
}
