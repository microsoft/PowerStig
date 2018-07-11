#region Header
using module .\..\..\..\Module\Convert.DnsServerSettingRule\Convert.DnsServerSettingRule.psm1
. $PSScriptRoot\.tests.header.ps1
#endregion
try
{
    #region Test Setup
    $DnsSettingsToTest = @(
        @{
            PropertyName  = 'EventLogLevel'
            PropertyValue = '4'
            CheckContent  = 'Log on to the DNS server using the Domain Admin or Enterprise Admin account.
        
        Press Windows Key + R, execute dnsmgmt.msc.
        
        Right-click the DNS server, select “Properties”.
        
        Click on the “Event Logging” tab. By default, all events are logged.
        
        Verify "Errors and warnings" or "All events" is selected.
        
        If any option other than "Errors and warnings" or "All events" is selected, this is a finding.'
        }
    )
    $rule = [DnsServerSettingRule]::new( (Get-TestStigRule -ReturnGroupOnly) )
    #endregion
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
    #endregion
    #region Method Tests
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
    #endregion
    #region Function Tests
    Describe "Private DnsServerSetting Rule tests" {

        # Regular expression tests
        Context "Dns Stig Rules regex tests" {
    
            [string] $text = 'the          forwarders     tab.'
            $result = ($text | 
                Select-String $script:regularExpression.textBetweenTheTab -AllMatches |
                    Select-Object Matches).Matches.Groups[1]
            It "Should match text inside of the words 'the' and 'tab'" {
                $result.Success | Should be $true
            }
            It "Should return text between the words 'the' and 'tab'" {
                $result.Value.trim() | Should Be 'forwarders'
            }

            [string] $text = ' âForwardersâ'
            It "Should match any non letter characters" {
                $result = $text -match $script:regularExpression.nonLetters
                $result | Should Be $true
            }
            It "Should remove the non word characters" {
                $result = $text -replace $script:regularExpression.nonLetters
                $result.Trim() | Should Be 'Forwarders'
            }
        }
    }

    Describe "ConvertTo-DnsServerSettingRule" {

        $stigRule = Get-TestStigRule -CheckContent $DnsSettingsToTest.checkContent -ReturnGroupOnly
        $rule = ConvertTo-DnsServerSettingRule -StigRule $stigRule
    
        It "Should return an DnsServerSettingRule object" {
            $rule.GetType() | Should Be 'DnsServerSettingRule'
        }
    }
    #endregion
    #region Data Tests

    #endregion
}
finally 
{
    . $PSScriptRoot\.tests.footer.ps1
}
