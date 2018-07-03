#region  Header
using module ..\..\..\..\src\public\class\WebAppPoolRuleClass.psm1
. $PSScriptRoot\..\..\..\helper.ps1
$ruleClassName = ($MyInvocation.MyCommand.Name -Split '\.')[0]
#endregion Header

#region Test Setup
$rule = [WebAppPoolrule]::new( (Get-TestStigRule -ReturnGroupOnly) )

$webAppPoolrule = @(
    @{
        Key           = 'rapidFailProtection'
        Value         = '$true'
        CheckContent  = 'Open the IIS 8.5 Manager.

        Click the Application Pools.
        
        Perform for each Application Pool.
        
        Highlight an Application Pool to review and click "Advanced Settings" in the "Actions" pane.
        
        Scroll down to the "Rapid Fail Protection" section and verify the value for "Enabled" is set to "True".
        
        If the "Rapid Fail Protection:Enabled" is not set to "True", this is a finding.'
    }
    @{
        Key           = 'pingingEnabled'
        Value         = '$true'
        CheckContent  = 'Open the IIS 8.5 Manager.

        Click the Application Pools.
        
        Perform for each Application Pool.
        
        Highlight an Application Pool to review and click "Advanced Settings" in the "Actions" pane.
        
        Scroll down to the "Process Model" section and verify the value for "Ping Enabled" is set to "True".

        If the value for "Ping Enabled" is not set to "True", this is a finding.'
    }
)

$OrganizationValueTestString = @{
    key = 'queueLength'
    TestString = '{0} -le 1000'
}
#endregion Test Setup

#region Class Tests
Describe "$ruleClassName Child Class" {
    
    Context 'Base Class' {
        
        It "Shoud have a BaseType of STIG" {
            $rule.GetType().BaseType.ToString() | Should Be 'STIG'
        }
    }

    Context 'Class Properties' {
        
        $classProperties = @('Key', 'Value')

        foreach ( $property in $classProperties )
        {
            It "Should have a property named '$property'" {
                ( $rule | Get-Member -Name $property ).Name | Should Be $property
            }
        }
    }

    Context 'Class Methods' {
        
        $classMethods = @('SetKeyValuePair', 'IsOrganizationalSetting', 'SetOrganizationValueTestString')

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
#endregion Class Tests

#region Method function Tests
foreach ( $rule in $webAppPoolrule )
{
    Describe 'Get-KeyValuePair' {
        It "Should return $($rule.Key) and $($rule.Value)" {
            $KeyValuePair = Get-KeyValuePair -CheckContent ($rule.CheckContent -split '\n')
            $KeyValuePair.Key | Should Be $rule.Key
            $KeyValuePair.Value | Should Be $rule.Value
        } 
    }
}

Describe 'Get-OrganizationValueTestString' {
    It "Should return two rules" {
        $testString = Get-OrganizationValueTestString -Key $OrganizationValueTestString.Key
        $testString | Should Be $OrganizationValueTestString.TestString
    } 
}
#endregion Method function Tests
