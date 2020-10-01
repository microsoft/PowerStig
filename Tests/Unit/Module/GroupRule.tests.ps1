#region Header
. $PSScriptRoot\.tests.header.ps1
#endregion

try
{
    InModuleScope -ModuleName "$($global:moduleName).Convert" {
        #region Test Setup
        $testRuleList = @(
            @{
                GroupName = 'Backup Operators'
                Members = $null
                MembersToExclude = $null
                OrganizationValueRequired = $false
                CheckContent = 'Run "Computer Management".
                Navigate to System Tools >> Local Users and Groups >> Groups.
                Review the members of the Backup Operators group.

                If the group contains no accounts, this is not a finding.

                If the group contains any accounts, the accounts must be specifically for backup functions.

                If the group contains any standard user accounts used for performing normal user tasks, this is a finding.'
            }
            @{
                GroupName = 'Administrators'
                Members = $null
                MembersToExclude = 'Domain Admins'
                OrganizationValueRequired = $false
                CheckContent = 'Run "Computer Management".
                Navigate to System Tools >> Local Users and Groups >> Groups.
                Review the members of the Administrators group.
                Only the appropriate administrator groups or accounts responsible for administration of the system may be members of the group.

                For domain-joined workstations, the Domain Admins group must be replaced by a domain workstation administrator group.

                Systems dedicated to the management of Active Directory (AD admin platforms, see V-36436 in the Active Directory Domain STIG) are exempt from this. AD admin platforms may use the Domain Admins group or a domain administrative group created specifically for AD admin platforms (see V-43711 in the Active Directory Domain STIG).

                Standard user accounts must not be members of the local administrator group.

                If prohibited accounts are members of the local administrators group, this is a finding.

                The built-in Administrator account or other required administrative accounts would not be a finding.'
            }
            @{
                GroupName = 'Hyper-V Administrators'
                Members = $null
                MembersToExclude = $null
                OrganizationValueRequired = $false
                CheckContent = 'Run "Computer Management".
                Navigate to System Tools >> Local Users and Groups >> Groups.
                Double click on "Hyper-V Administrators".

                If any groups or user accounts are listed in "Members:", this is a finding.

                If the workstation has an approved use of Hyper-V, such as being used as a dedicated admin workstation using Hyper-V to separate administration and standard user functions, the account(s) needed to access the virtual machine is not a finding.'
            }
        )
        #endregion

        foreach ($testRule in $testRuleList)
        {
            . $PSScriptRoot\Convert.CommonTests.ps1
        }

        #region Add Custom Tests Here

        #endregion
    }
}
finally
{
    . $PSScriptRoot\.tests.footer.ps1
}
