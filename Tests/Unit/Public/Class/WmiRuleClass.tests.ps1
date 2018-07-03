#########################################      Header      #########################################
using module ..\..\..\..\src\public\class\WmiRuleClass.psm1
. $PSScriptRoot\..\..\..\helper.ps1
$ruleClassName = ($MyInvocation.MyCommand.Name -Split '\.')[0]
#########################################      Header      #########################################
#########################################    Test Setup    #########################################
$rule = [WmiRule]::new( (Get-TestStigRule -ReturnGroupOnly) )
#########################################    Test Setup    #########################################
#########################################    Class Tests   #########################################
Describe "$ruleClassName Child Class" {
    
    Context 'Base Class' {

        It "Shoud have a BaseType of STIG" {
            $rule.GetType().BaseType.ToString() | Should Be 'STIG'
        }
    }

    Context 'Class Properties' {

        $classProperties = @('Query', 'Property', 'Value', 'Operator')

        foreach ( $property in $classProperties )
        {
            It "Should have a property named '$property'" {
                ( $rule | Get-Member -Name $property ).Name | Should Be $property
            }
        }
    }

    Context 'Class Methods' {

        $classMethods = @()

        foreach ( $method in $classMethods )
        {
            It "Should have a method named '$method'" {
                ($rule | Get-Member -Name $method).Name | Should Be $method
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

