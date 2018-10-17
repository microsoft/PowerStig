#region Header
using module .\..\..\..\Module\Convert.UserRightsAssignmentRule\Convert.UserRightsAssignmentRule.psm1
. $PSScriptRoot\.tests.header.ps1
#endregion
try
{
    InModuleScope -ModuleName $script:moduleName {
        #region Test Setup
        $rulesToTest = @(
            @{
                DisplayName  = 'Deny access to this computer from the network'
                Constant     = 'SeDenyNetworkLogonRight'
                Identity     = 'Guests'
                ForceFlag    = $false
                CheckContent = 'Run "gpedit.msc".

                Navigate to Local Computer Policy -&gt; Computer Configuration -&gt; Windows Settings -&gt; Security Settings -&gt; Local Policies -&gt; User Rights Assignment.

                If the following accounts or groups are not defined for the "Deny access to this computer from the network" user right, this is a finding:

                Guests Group'
            },
            @{
                DisplayName  = 'Access this computer from the network'
                Constant     = 'SeNetworkLogonRight'
                Identity     = @('Administrators', 'Authenticated Users', 'Enterprise Domain Controllers' )
                ForceFlag    = $true
                CheckContent = 'Run "gpedit.msc".

                Navigate to Local Computer Policy -&gt; Computer Configuration -&gt; Windows Settings -&gt; Security Settings -&gt; Local Policies -&gt; User Rights Assignment.

                If any accounts or groups other than the following are granted the "Access this computer from the network" right, this is a finding:

                Administrators
                Authenticated Users
                Enterprise Domain Controllers'
            },
            @{
                DisplayName  = 'Debug programs'
                Constant     = 'SeDebugPrivilege'
                Identity     = 'Administrators'
                ForceFlag    = $true
                CheckContent = 'Verify the effective setting in Local Group Policy Editor.
                Run "gpedit.msc".

                Navigate to Local Computer Policy -&gt; Computer Configuration -&gt; Windows Settings -&gt; Security Settings -&gt; Local Policies -&gt; User Rights Assignment.

                If any accounts or groups other than the following are granted the "Debug programs" user right, this is a finding:

                Administrators'
            },
            @{
                DisplayName  = 'Create a token object'
                Constant     = 'SeCreateTokenPrivilege'
                Identity     = 'NULL'
                ForceFlag    = $true
                CheckContent = 'Verify the effective setting in Local Group Policy Editor.
                Run "gpedit.msc".

                Navigate to Local Computer Policy -&gt; Computer Configuration -&gt; Windows Settings -&gt; Security Settings -&gt; Local Policies -&gt; User Rights Assignment.

                If any accounts or groups are granted the "Create a token object" user right, this is a finding.'
            },
            @{
                DisplayName  = 'Access Credential Manager as a trusted caller'
                Constant     = 'SeTrustedCredManAccessPrivilege'
                Identity     = 'NULL'
                ForceFlag    = $true
                CheckContent = 'Verify the effective setting in Local Group Policy Editor.
                Run "gpedit.msc".

                Navigate to Local Computer Policy -&gt; Computer Configuration -&gt; Windows Settings -&gt; Security Settings -&gt; Local Policies -&gt; User Rights Assignment.

                If any accounts or groups are granted the "Access Credential Manager as a trusted caller" user right, this is a finding.'
            },
            @{
                DisplayName  = 'Deny log on as a service'
                Constant     = 'SeDenyServiceLogonRight'
                Identity     = 'NULL'
                ForceFlag    = $true
                CheckContent = 'Verify the effective setting in Local Group Policy Editor.
                Run "gpedit.msc".

                Navigate to Local Computer Policy -&gt; Computer Configuration -&gt; Windows Settings -&gt; Security Settings -&gt; Local Policies -&gt; User Rights Assignment.

                If any accounts or groups are defined for the "Deny log on as a service" user right, this is a finding.'
            },
            @{
                DisplayName  = 'Manage auditing and security log'
                Constant     = 'SeSecurityPrivilege'
                Identity     = 'Administrators'
                ForceFlag    = $true
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
                DisplayName  = 'Take ownership of files or other objects'
                Constant     = 'SeTakeOwnershipPrivilege'
                Identity     = 'Administrators'
                ForceFlag    = $true
                CheckContent = 'Verify the effective setting in Local Group Policy Editor.
                Run "gpedit.msc".

                Navigate to Local Computer Policy &gt;&gt; Computer Configuration &gt;&gt; Windows Settings &gt;&gt; Security Settings &gt;&gt; Local Policies &gt;&gt; User Rights Assignment.

                If any groups or accounts other than the following are granted the "Take ownership of files or other objects" user right, this is a finding:

                Administrators'
            },
            @{
                DisplayName  = 'Lock pages in memory'
                Constant     = 'SeLockMemoryPrivilege'
                Identity     = 'NULL'
                ForceFlag    = $true
                CheckContent = 'Verify the effective setting in Local Group Policy Editor.
                Run "gpedit.msc".

                Navigate to Local Computer Policy &gt;&gt; Computer Configuration &gt;&gt; Windows Settings &gt;&gt; Security Settings &gt;&gt; Local Policies &gt;&gt; User Rights Assignment.

                If any groups or accounts are granted the "Lock pages in memory" user right, this is a finding.'
            },
            @{
                DisplayName  = 'Deny log on through Remote Desktop Services'
                Constant     = 'SeDenyRemoteInteractiveLogonRight'
                Identity     = @('Enterprise Admins', 'Domain Admins', 'Local account', 'Guests')
                ForceFlag    = $false
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
                DisplayName  = 'Deny log on locally'
                Constant     = 'SeDenyInteractiveLogonRight'
                Identity     = @('Enterprise Admins', 'Domain Admins', 'Guests')
                ForceFlag    = $false
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
            }
        )

        $stigRule = Get-TestStigRule -CheckContent $rulesToTest[0].CheckContent -ReturnGroupOnly
        $rule = [UserRightRule]::new( $stigRule )
        #endregion
        #region Class Tests
        Describe "$($rule.GetType().Name) Child Class" {

            Context 'Base Class' {

                It "Shoud have a BaseType of Rule" {
                    $rule.GetType().BaseType.ToString() | Should Be 'Rule'
                }
            }

            Context 'Class Properties' {

                $classProperties = @('DisplayName', 'Constant', 'Identity', 'Force')

                foreach ( $property in $classProperties )
                {
                    It "Should have a property named '$property'" {
                        ( $rule | Get-Member -Name $property ).Name | Should Be $property
                    }
                }
            }
        }
        #endregion
        #region Method Tests
        Describe 'Get-UserRightDisplayName' {

            foreach ( $rule in $rulesToTest )
            {
                It "Should return $($rule.DisplayName)" {
                    $checkContent = Split-TestStrings -CheckContent $rule.CheckContent
                    $result = Get-UserRightDisplayName -CheckContent $checkContent
                    $result | Should Be $rule.DisplayName
                }
            }
        }

        Describe 'Get-UserRightConstant' {

            foreach ( $rule in $rulesToTest.GetEnumerator() )
            {
                It "Should return $($rule.Constant) from $($rule.DisplayName)" {
                    $result = Get-UserRightConstant -UserRightDisplayName $rule.DisplayName
                    $result | Should Be $rule.Constant
                }
            }
        }

        Describe 'Get-UserRightIdentity' {

            foreach ( $rule in $rulesToTest.GetEnumerator() )
            {
                It "Should return $($rule.Identity)" {
                    $checkContent = Split-TestStrings -CheckContent $rule.CheckContent
                    $result = Get-UserRightIdentity -CheckContent $checkContent
                    $result | Should Be $rule.Identity
                }
            }
        }

        Describe 'Test-SetForceFlag' {

            foreach ( $rule in $rulesToTest.GetEnumerator() )
            {
                It "Should return $($rule.ForceFlag)" {
                    $checkContent = Split-TestStrings -CheckContent $rule.CheckContent
                    $result = Test-SetForceFlag -CheckContent $checkContent
                    $result | Should Be $rule.ForceFlag
                }
            }
        }

        Describe 'Test-MultipleUserRightsAssignment' {
            $checkContent = 'Review the DNS server to confirm the server restricts direct and remote console access to users other than Administrators.

            Verify the effective setting in Local Group Policy Editor.

            Run "gpedit.msc".

            Navigate to Local Computer Policy &gt;&gt; Computer Configuration &gt;&gt; Windows Settings &gt;&gt; Security Settings &gt;&gt; Local Policies &gt;&gt; User Rights Assignment.

            If any accounts or groups other than the following are granted the "Allow log on through Remote Desktop Services" user right, this is a finding:

            Administrators

            Navigate to Local Computer Policy &gt;&gt; Computer Configuration &gt;&gt; Windows Settings &gt;&gt; Security Settings &gt;&gt; Local Policies &gt;&gt; User Rights Assignment.

            If the following accounts or groups are not defined for the "Deny access to this computer from the network" user right, this is a finding:

            Guests Group'

            $checkContent = Split-TestStrings -CheckContent $checkContent
            It "Should return $true if multiple policies settings are found" {
                Test-MultipleUserRightsAssignment -CheckContent $checkContent | Should Be $true
            }
            It "Should return $false if multiple policies settings are not found" {
                $results = Test-MultipleUserRightsAssignment -CheckContent $checkContent[0..3]
                $results | Should Be $false
            }
        }

        Describe 'Split-MultipleUserRightsAssignment' {
            $firstUserRightsAssignment = 'Navigate to Local Computer Policy &gt;&gt; Computer Configuration &gt;&gt; Windows Settings &gt;&gt; Security Settings &gt;&gt; Local Policies &gt;&gt; User Rights Assignment.

            If any accounts or groups other than the following are granted the "Allow log on through Remote Desktop Services" user right, this is a finding:

            Administrators'

            $secondUserRightsAssignment = 'Navigate to Local Computer Policy &gt;&gt; Computer Configuration &gt;&gt; Windows Settings &gt;&gt; Security Settings &gt;&gt; Local Policies &gt;&gt; User Rights Assignment.

            If the following accounts or groups are not defined for the "Deny access to this computer from the network" user right, this is a finding:

            Guests Group'
            $checkContent = 'Review the DNS server to confirm the server restricts direct and remote console access to users other than Administrators.

            Verify the effective setting in Local Group Policy Editor.

            Run "gpedit.msc".
            {0}
            {1}'

            $composedContent = $checkContent -f $firstUserRightsAssignment, $secondUserRightsAssignment
            $checkContent = Split-TestStrings -CheckContent $composedContent
            $results = Split-MultipleUserRightsAssignment -CheckContent $checkContent

            Context 'First User Right' {

                It "Should return the first " {
                    $results[0] | Should Match 'Allow log on through Remote Desktop Services'
                }
                It "Should Not return the second" {
                    $results[0] | Should Not Match 'Deny access to this computer from the network'
                }
            }

            Context 'Second User Right' {

                It "Should return the second" {
                    $results[1] | Should Match 'Deny access to this computer from the network'
                }
                It "Should Not return the first" {
                    $results[1] | Should Not Match 'Allow log on through Remote Desktop Services'
                }
            }
        }
        #endregion

        #region Data Tests
        Describe "UserRightNameToConstant Data Section" {

            [string] $dataSectionName = 'UserRightNameToConstant'

            It "Should have a data section called $dataSectionName" {
                ( Get-Variable -Name $dataSectionName ).Name | Should Be $dataSectionName
            }

            <#
            TO DO - Add rules
            #>
        }
        #endregion
    }
}
finally
{
    . $PSScriptRoot\.tests.footer.ps1
}
