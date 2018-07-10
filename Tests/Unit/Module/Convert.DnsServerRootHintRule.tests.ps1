#region Header
using module .\..\..\..\Module\Convert.DnsServerRootHintRule\Convert.DnsServerRootHintRule.psm1
. $PSScriptRoot\.tests.header.ps1
#endregion
try
{
    #region Test Setup
    $rule = [DnsServerRootHintRule]::new( (Get-TestStigRule -ReturnGroupOnly) )
    #endregion
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

    #endregion
    #region Method Tests

    #endregion
    #region Function Tests
    Describe "ConvertTo-DnsServerRootHintRule" {
        $checkContent = 'Note: If the Windows DNS server is in the classified network, this check is Not Applicable.

Log on to the authoritative DNS server using the Domain Admin or Enterprise Admin account.

Press Windows Key + R, execute dnsmgmt.msc.

Right-click the DNS server, select “Properties”.

Select the "Root Hints" tab.

Verify the "Root Hints" is either empty or only has entries for internal zones under "Name servers:". All Internet root server entries must be removed.

If "Root Hints" is not empty and the entries on the "Root Hints" tab under "Name servers:" are external to the local network, this is a finding.'
        
        $stigRule = Get-TestStigRule -CheckContent $checkContent -ReturnGroupOnly
        $rule = ConvertTo-DnsServerRootHintRule -StigRule $stigRule

        It "Should return an DnsServerRootHintRule object" {
            $rule.GetType() | Should Be 'DnsServerRootHintRule'
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
