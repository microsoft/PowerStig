using module ..\..\..\..\Public\Class\Convert.DnsServerSettingRule.psm1
#region Convert Public Class Header V1
. $PSScriptRoot\.Convert.Test.Header.ps1
#endregion
#region Test Setup
$rule = [DnsServerSettingRule]::new( (Get-TestStigRule -ReturnGroupOnly) )

$DnsSettingsToTest = @(
    @{
        PropertyName  = 'EventLogLevel'
        PropertyValue  = '4'
        CheckContent = 'Log on to the DNS server using the Domain Admin or Enterprise Admin account.
        
        Press Windows Key + R, execute dnsmgmt.msc.
        
        Right-click the DNS server, select “Properties”.
        
        Click on the “Event Logging” tab. By default, all events are logged.
        
        Verify "Errors and warnings" or "All events" is selected.
        
        If any option other than "Errors and warnings" or "All events" is selected, this is a finding.'
    }
)
#endregion Test Setup

#region Class Tests
Describe "$($rule.GetType().Name) Child Class" {
    
    Context 'Base Class' {
        
        It "Shoud have a BaseType of STIG" {
            $rule.GetType().BaseType.ToString() | Should Be 'STIG'
        }
    }

    Context 'Class Properties' {
        
        $classProperties = @('PropertyName', 'PropertyValue')

        foreach ( $property in $classProperties )
        {
            It "Should have a property named '$property'" {
                ( $rule | Get-Member -Name $property ).Name | Should Be $property
            }
        }
    }

    Context 'Class Methods' {
        
        $classMethods = @('SetDnsServerPropertyName', 'SetDnsServerPropertyValue')

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
Describe 'Get-DnsServerSettingProperty' {

    foreach ( $setting in $DnsSettingsToTest )
    {
        It "Should return '$($setting.PropertyName)'" {
            $DnsServerSettingProperty = Get-DnsServerSettingProperty -CheckContent ($setting.CheckContent -split '\n')
            $DnsServerSettingProperty | Should Be $setting.PropertyName
        } 
    }
}

Describe 'Get-DnsServerSettingPropertyValue' {
    
    foreach ( $setting in $DnsSettingsToTest )
    {
        It "Should return '$($setting.PropertyValue)'" {
            $DnsServerSettingProperty = Get-DnsServerSettingPropertyValue -CheckContent ($setting.CheckContent -split '\n')
            $DnsServerSettingProperty | Should Be $setting.PropertyValue
        } 
    }
}
#endregion Method function Tests
