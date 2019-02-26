#region Header
using module .\..\..\..\Module\Rule.UserRight\Convert\UserRightRule.Convert.psm1
. $PSScriptRoot\.tests.header.ps1
#endregion

try
{
    InModuleScope -ModuleName "$($global:moduleName).Convert" {
        #region Test Setup
        $testRuleList = @(
            @{
                DisplayName = 'Deny access to this computer from the network'
                Constant = 'SeDenyNetworkLogonRight'
                Identity = 'Guests'
                Force = $false
                OrganizationValueRequired = $false
                CheckContent = 'Run "gpedit.msc".

                Navigate to Local Computer Policy -&gt; Computer Configuration -&gt; Windows Settings -&gt; Security Settings -&gt; Local Policies -&gt; User Rights Assignment.

                If the following accounts or groups are not defined for the "Deny access to this computer from the network" user right, this is a finding:

                Guests Group'
            },
            @{
                DisplayName = 'Access this computer from the network'
                Constant = 'SeNetworkLogonRight'
                Identity = 'Administrators,Authenticated Users,Enterprise Domain Controllers'
                Force = $true
                OrganizationValueRequired = $false
                CheckContent = 'Run "gpedit.msc".

                Navigate to Local Computer Policy -&gt; Computer Configuration -&gt; Windows Settings -&gt; Security Settings -&gt; Local Policies -&gt; User Rights Assignment.

                If any accounts or groups other than the following are granted the "Access this computer from the network" right, this is a finding:

                Administrators
                Authenticated Users
                Enterprise Domain Controllers'
            },
            @{
                DisplayName = 'Debug programs'
                Constant = 'SeDebugPrivilege'
                Identity = 'Administrators'
                Force = $true
                OrganizationValueRequired = $false
                CheckContent = 'Verify the effective setting in Local Group Policy Editor.
                Run "gpedit.msc".

                Navigate to Local Computer Policy -&gt; Computer Configuration -&gt; Windows Settings -&gt; Security Settings -&gt; Local Policies -&gt; User Rights Assignment.

                If any accounts or groups other than the following are granted the "Debug programs" user right, this is a finding:

                Administrators'
            },
            @{
                DisplayName = 'Create a token object'
                Constant = 'SeCreateTokenPrivilege'
                Identity = 'NULL'
                Force = $true
                OrganizationValueRequired = $false
                CheckContent = 'Verify the effective setting in Local Group Policy Editor.
                Run "gpedit.msc".

                Navigate to Local Computer Policy -&gt; Computer Configuration -&gt; Windows Settings -&gt; Security Settings -&gt; Local Policies -&gt; User Rights Assignment.

                If any accounts or groups are granted the "Create a token object" user right, this is a finding.'
            },
            @{
                DisplayName = 'Access Credential Manager as a trusted caller'
                Constant = 'SeTrustedCredManAccessPrivilege'
                Identity = 'NULL'
                Force = $true
                OrganizationValueRequired = $false
                CheckContent = 'Verify the effective setting in Local Group Policy Editor.
                Run "gpedit.msc".

                Navigate to Local Computer Policy -&gt; Computer Configuration -&gt; Windows Settings -&gt; Security Settings -&gt; Local Policies -&gt; User Rights Assignment.

                If any accounts or groups are granted the "Access Credential Manager as a trusted caller" user right, this is a finding.'
            },
            @{
                DisplayName = 'Deny log on as a service'
                Constant = 'SeDenyServiceLogonRight'
                Identity = 'NULL'
                Force = $true
                OrganizationValueRequired = $false
                CheckContent = 'Verify the effective setting in Local Group Policy Editor.
                Run "gpedit.msc".

                Navigate to Local Computer Policy -&gt; Computer Configuration -&gt; Windows Settings -&gt; Security Settings -&gt; Local Policies -&gt; User Rights Assignment.

                If any accounts or groups are defined for the "Deny log on as a service" user right, this is a finding.'
            },
            @{
                DisplayName = 'Manage auditing and security log'
                Constant = 'SeSecurityPrivilege'
                Identity = 'Administrators'
                Force = $true
                OrganizationValueRequired = $false
                CheckContent = 'Verify the effective setting in Local Group Policy Editor.
                Run "gpedit.msc".

                Navigate to Local Computer Policy &gt;&gt; Computer Configuration &gt;&gt; Windows Settings &gt;&gt; Security Settings &gt;&gt; Local Policies &gt;&gt; User Rights Assignment.

                If any accounts or groups other than the following are granted the "Manage auditing and security log" user right, this is a finding:

                Administrators

                If the organization has an Auditors group, the assignment of this group to the user right would not be a finding.

                If an application requires this user right, this would not be a finding.
                Vendor documentation must support the requirement for having the user right.
                The requirement must be documented with the ISSO.
                The application account must meet requirements for application account passwords, such as length (V-36661) and required changes frequency (V-36662).'
            },
            @{
                <#
                    The next two strings to test verify CheckContent with the phrase 'groups or accounts' are parsed correctly. This edge case is apparent in the Windows 10 STIG.
                    In the MS STIG the wording used is 'accounts or groups'
                #>
                DisplayName = 'Take ownership of files or other objects'
                Constant = 'SeTakeOwnershipPrivilege'
                Identity = 'Administrators'
                Force = $true
                OrganizationValueRequired = $false
                CheckContent = 'Verify the effective setting in Local Group Policy Editor.
                Run "gpedit.msc".

                Navigate to Local Computer Policy &gt;&gt; Computer Configuration &gt;&gt; Windows Settings &gt;&gt; Security Settings &gt;&gt; Local Policies &gt;&gt; User Rights Assignment.

                If any groups or accounts other than the following are granted the "Take ownership of files or other objects" user right, this is a finding:

                Administrators'
            },
            @{
                DisplayName = 'Lock pages in memory'
                Constant = 'SeLockMemoryPrivilege'
                Identity = 'NULL'
                Force = $true
                OrganizationValueRequired = $false
                CheckContent = 'Verify the effective setting in Local Group Policy Editor.
                Run "gpedit.msc".

                Navigate to Local Computer Policy &gt;&gt; Computer Configuration &gt;&gt; Windows Settings &gt;&gt; Security Settings &gt;&gt; Local Policies &gt;&gt; User Rights Assignment.

                If any groups or accounts are granted the "Lock pages in memory" user right, this is a finding.'
            },
            @{
                DisplayName = 'Deny log on through Remote Desktop Services'
                Constant = 'SeDenyRemoteInteractiveLogonRight'
                Identity = 'Enterprise Admins,Domain Admins,Local account,Guests'
                Force = $false
                OrganizationValueRequired = $false
                CheckContent = 'Verify the effective setting in Local Group Policy Editor.
                Run "gpedit.msc".

                Navigate to Local Computer Policy &gt;&gt; Computer Configuration &gt;&gt; Windows Settings &gt;&gt; Security Settings &gt;&gt; Local Policies &gt;&gt; User Rights Assignment.

                If the following groups or accounts are not defined for the "Deny log on through Remote Desktop Services" right, this is a finding:

                If Remote Desktop Services is not used by the organization, the Everyone group can replace all of the groups listed below.

                Domain Systems Only:
                Enterprise Admin group
                Domain Admin group
                Local account (see Note below)

                All Systems:
                Guests group

                Systems dedicated to the management of Active Directory (AD admin platforms, see V-36436 in the Active Directory Domain STIG) are exempt from denying the Enterprise Admins and Domain Admins groups.

                Note: "Local account" is a built-in security group used to assign user rights and permissions to all local accounts.'
            },
            @{
                DisplayName = 'Deny log on locally'
                Constant = 'SeDenyInteractiveLogonRight'
                Identity = 'Enterprise Admins,Domain Admins,Guests'
                Force = $false
                OrganizationValueRequired = $false
                CheckContent = 'Verify the effective setting in Local Group Policy Editor.
                Run "gpedit.msc".

                Navigate to Local Computer Policy &gt;&gt; Computer Configuration &gt;&gt; Windows Settings &gt;&gt; Security Settings &gt;&gt; Local Policies &gt;&gt; User Rights Assignment.

                If the following groups or accounts are not defined for the "Deny log on locally" right, this is a finding.

                Domain Systems Only:
                Enterprise Admins Group
                Domain Admins Group

                Workstations dedicated to the management of Active Directory (see V-36436 in the Active Directory Domain STIG) are exempt from this.

                All Systems:
                Guests Group'
            },
            @{
                DisplayName = 'Access this computer from the network'
                Constant = 'SeNetworkLogonRight'
                Identity = 'Administrators,Authenticated Users,Enterprise Domain Controllers'
                Force = $true
                OrganizationValueRequired = $false
                CheckContent = 'This applies to domain controllers. It is NA for other systems.

                Verify the effective setting in Local Group Policy Editor.

                Run "gpedit.msc".

                Navigate to Local Computer Policy &gt;&gt; Computer Configuration &gt;&gt; Windows Settings &gt;&gt; Security Settings &gt;&gt; Local Policies &gt;&gt; User Rights Assignment.

                If any accounts or groups other than the following are granted the "Access this computer from the network" right, this is a finding.

                - Administrators
                - Authenticated Users
                - Enterprise Domain Controllers

                If an application requires this user right, this would not be a finding.

                Vendor documentation must support the requirement for having the user right.

                The requirement must be documented with the ISSO.

                The application account must meet requirements for application account passwords, such as length (WN16-00-000060) and required frequency of changes (WN16-00-000070).'
            }
        )
        #endregion

        foreach ($testRule in $testRuleList)
        {
            . $PSScriptRoot\Convert.CommonTests.ps1
        }

        #region Add Custom Tests Here
        Describe 'MultipleRules' {
            # TODO move this to the CommonTests
            $testRuleList = @(
                @{
                    Count = 2
                    CheckContent = 'Review the DNS server to confirm the server restricts direct and remote console access to users other than Administrators.

                    Verify the effective setting in Local Group Policy Editor.

                    Run "gpedit.msc".
                    {0}
                    {1}'
                    FirstUserRightsAssignment = 'Navigate to Local Computer Policy &gt;&gt; Computer Configuration &gt;&gt; Windows Settings &gt;&gt; Security Settings &gt;&gt; Local Policies &gt;&gt; User Rights Assignment.

                    If any accounts or groups other than the following are granted the "Allow log on through Remote Desktop Services" user right, this is a finding:

                    Administrators'

                    SecondUserRightsAssignment = 'Navigate to Local Computer Policy &gt;&gt; Computer Configuration &gt;&gt; Windows Settings &gt;&gt; Security Settings &gt;&gt; Local Policies &gt;&gt; User Rights Assignment.

                    If the following accounts or groups are not defined for the "Deny access to this computer from the network" user right, this is a finding:

                    Guests Group'
                }
            )
            foreach ($testRule in $testRuleList)
            {
                It "Should return $true if multiple policies settings are found" {
                    $checkContent = $testRule.CheckContent -f $testRule.FirstUserRightsAssignment, $testRule.SecondUserRightsAssignment
                    $multipleRule = [UserRightRuleConvert]::HasMultipleRules($checkContent)
                    $multipleRule | Should -Be $true
                }
                It "Should return $false if multiple policies settings are not found" {
                    $checkContent = $testRule.CheckContent -f $testRule.FirstUserRightsAssignment, ''
                    $multipleRule = [UserRightRuleConvert]::HasMultipleRules($checkContent)
                    $multipleRule | Should -Be $false
                }

                Context 'Split Rules' {
                    $checkContent = $testRule.CheckContent -f $testRule.FirstUserRightsAssignment, $testRule.SecondUserRightsAssignment
                    $multipleRule = [UserRightRuleConvert]::SplitMultipleRules($checkContent)
                    It 'Should return the first' {
                        $multipleRule[0] | Should -Match 'Allow log on through Remote Desktop Services'
                    }
                    It 'Should Not return the second' {
                        $multipleRule[0] | Should -Not -Match 'Deny access to this computer from the network'
                    }
                    It 'Should return the second' {
                        $multipleRule[1] | Should -Match 'Deny access to this computer from the network'
                    }
                    It 'Should Not return the first' {
                        $multipleRule[1] | Should -Not -Match 'Allow log on through Remote Desktop Services'
                    }
                }
            }
        }
        #endregion
    }
}
finally
{
    . $PSScriptRoot\.tests.footer.ps1
}
