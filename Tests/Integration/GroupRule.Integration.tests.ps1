## There is nor current group rule to verify against. The current example is being parsed as a manual rule.
## Commented out to keep the work and reuse later if needed but not run the tests until then
<#
#region Header
. $PSScriptRoot\.tests.header.ps1
#endregion

try
{
    #region Test Setup
    $groupRulesToTest = @(
        @{
            GroupName        = 'Administrators'
            MembersToExclude = 'Domain Admins'
            CheckContent     = 'Run "Computer Management".
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
    #endregion
    #region Tests
    Describe "GroupRule Integration Tests" {
        foreach ($groupRule in $groupRulesToTest)
        {
            [xml] $StigRule = Get-TestStigRule -CheckContent $groupRule.CheckContent -XccdfTitle Windows
            $TestFile = Join-Path -Path $TestDrive -ChildPath 'TextData.xml'
            $StigRule.Save( $TestFile )
            $rule = ConvertFrom-StigXccdf -Path $TestFile

            It 'Should be a GroupRule' {
                $rule.GetType() | Should Be 'GroupRule'
            }
            It "Should return GroupName:'$($rule.GroupName)'" {
                $rule.GroupName | Should Be $groupRule.GroupName
            }
            It "Should return MembersToExclude:'$($rule.MembersToExclude)'" {
                $rule.MembersToExclude | Should Be $groupRule.MembersToExclude
            }
            It "Should set the correct DscResource" {
                $rule.DscResource | Should Be 'Group'
            }
        }
    }
    #endregion
}
finally
{
    . $PSScriptRoot\.tests.footer.ps1
}
#>
