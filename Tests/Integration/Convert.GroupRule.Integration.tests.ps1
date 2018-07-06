#region Header
. $PSScriptRoot\.Convert.Integration.Tests.Header.ps1
#endregion
#region Test Setup
$groupRulesToTest = @(
    @{
        GroupName    = 'Administrators'
        MembersToExclude      = 'Domain Admins'
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
)

Describe "GroupRule Integration Tests" {
    foreach ($groupRule in $groupRulesToTest)
    {
        [xml] $StigRule = Get-TestStigRule -CheckContent $groupRule.CheckContent -XccdfTitle Windows
        $TestFile = Join-Path -Path $TestDrive -ChildPath 'TextData.xml'
        $StigRule.Save( $TestFile )
        $rule = ConvertFrom-StigXccdf -Path $TestFile

        It 'Should be a GroupRule' {
            $rule.GetType().Name -eq 'GroupRule' | Should Be $true
        }

        It "Should return GroupName:'$($rule.GroupName)'" {
            $rule.GroupName | Should Be $groupRule.GroupName
        }

        It "Should return MembersToExclude:'$($rule.MembersToExclude)'" {
            $rule.MembersToExclude | Should Be $groupRule.MembersToExclude
        }
    }
}
