using module ..\..\..\..\Public\Class\Convert.ManualRule.psm1
#region Convert Public Class Header V1
. $PSScriptRoot\.Convert.Test.Header.ps1
#endregion
#region Test Setup
$rule = [ManualRule]::new( (Get-TestStigRule -ReturnGroupOnly) )

$checkContentBase = 'Verify servers are located in controlled access areas that are accessible only to authorized personnel.  If systems are not adequately protected, this is a finding.'
#endregion
#region Class Tests
Describe "$($rule.GetType().Name) Child Class" {

    Context 'Base Class' {
        
        It "Shoud have a BaseType of STIG" {
            $rule.GetType().BaseType.ToString() | Should Be 'STIG'
        }
    }

    Context 'Class Properties' {}

    Context 'Class Methods' {
        $classMethods = @()

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
