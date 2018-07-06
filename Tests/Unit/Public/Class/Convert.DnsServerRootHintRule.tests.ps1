using module ..\..\..\..\Public\Class\Convert.DnsServerRootHintRule.psm1
#region Convert Public Class Header V1
. $PSScriptRoot\.Convert.Test.Header.ps1
#endregion
#region Test Setup
$rule = [DnsServerRootHintRule]::new( (Get-TestStigRule -ReturnGroupOnly) )

#endregion Test Setup

#region Class Tests
Describe "$($rule.GetType().Name) Child Class" {

    Context 'Base Class' {

        It "Shoud have a BaseType of STIG" {
            $rule.GetType().BaseType.ToString() | Should Be 'STIG'
        }
    }

    Context 'Class Properties' {

        $classProperties = @('HostName', 'IpAddress')

        foreach ( $property in $classProperties )
        {
            It "Should have a property named '$property'" {
                ( $rule | Get-Member -Name $property ).Name | Should Be $property
            }
        }
    }

    Context 'Class Methods' {

        $classMethods = @()

        # If new methods are added this will catch them so test coverage can be added
        It "Should not have more methods than are tested" {
            $memberPlanned = Get-StigBaseMethods -ChildClassMethodNames $classMethods
            $memberActual = ( $rule | Get-Member -MemberType Method ).Name
            $compare = Compare-Object -ReferenceObject $memberActual -DifferenceObject $memberPlanned
            $compare.Count | Should Be 0
        }
    }
}
#endregion Class Tests
