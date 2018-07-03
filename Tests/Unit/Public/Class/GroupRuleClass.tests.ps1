#region  Header
using module ..\..\..\..\src\public\class\GroupRuleClass.psm1
. $PSScriptRoot\..\..\..\helper.ps1
$ruleClassName = ($MyInvocation.MyCommand.Name -Split '\.')[0]
#endregion Header

#region Test Setup
$rule = [GroupRule]::new( (Get-TestStigRule -ReturnGroupOnly) )

$groupRulesToTest = @(
    @{
        GroupName    = 'Backup Operators'
        CheckContent = 'Run "Computer Management".
        Navigate to System Tools >> Local Users and Groups >> Groups.
        Review the members of the Backup Operators group.
        
        If the group contains no accounts, this is not a finding.
        
        If the group contains any accounts, the accounts must be specifically for backup functions.
        
        If the group contains any standard user accounts used for performing normal user tasks, this is a finding.'
    }
    @{
        GroupName    = 'Administrators'
        Members      = 'Domain Admins'
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
        GroupName    = 'Hyper-V Administrators'
        CheckContent = 'Run "Computer Management".
        Navigate to System Tools >> Local Users and Groups >> Groups.
        Double click on "Hyper-V Administrators".

        If any groups or user accounts are listed in "Members:", this is a finding.

        If the workstation has an approved use of Hyper-V, such as being used as a dedicated admin workstation using Hyper-V to separate administration and standard user functions, the account(s) needed to access the virtual machine is not a finding.'
    }
)

#region Class Tests
Describe "$ruleClassName Child Class" {
    
    Context 'Base Class' {
        
        It "Shoud have a BaseType of STIG" {
            $rule.GetType().BaseType.ToString() | Should Be 'STIG'
        }
    }

    Context 'Class Properties' {
        
        $classProperties = @('GroupName', 'MembersToExclude')

        foreach ( $property in $classProperties )
        {
            It "Should have a property named '$property'" {
                ( $rule | Get-Member -Name $property ).Name | Should Be $property
            }
        }
    }

    Context 'Class Methods' {
        
        $classMethods = @('SetGroupName', 'SetMembersToExclude')

        foreach ( $method in $classMethods )
        {
            It "Should have a method named '$method'" {
                ( $rule | Get-Member -Name $method ).Name | Should Be $method
            }
        }

        # If new methods are added this will catch them so test coverage can be added
        It "Should not have more methods than are tested" {
            $memberPlanned = Get-StigBaseMethods -ChildClassMethodNames $classMethods
            $memberActual = ( $rule | Get-Member -MemberType Method ).Name
            $compare = Compare-Object -ReferenceObject $memberActual -DifferenceObject $memberPlanned
            $compare.Count | Should Be 0
        }
    }
}
#endregion

# region Method function tests
Describe 'Get-GroupDetail' {
    Context 'Test correct GroupName is returned' {
        foreach ( $rule in $groupRulesToTest )
        {
            It "Should be a GroupName of  '$($rule.GroupName)'" {
                $result = Get-GroupDetail -CheckContent $rule.CheckContent.Trim()
                $result.GroupName | Should Be $rule.GroupName
            }
        }
    }

    Context 'Test correct Members is returned' {
        foreach ( $rule in $groupRulesToTest )
        {
            if ($rule.Members)
            {
                It "Should be Members '$($rule.Members)'" {
                    $result = Get-GroupDetail -CheckContent $rule.CheckContent.Trim()
                    $result.Members | Should Be $rule.Members
                }
            }
        }
    }
}


