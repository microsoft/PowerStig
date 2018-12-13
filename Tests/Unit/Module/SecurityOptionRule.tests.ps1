#region Header
using module .\..\..\..\Module\SecurityOptionRule\SecurityOptionRule.psm1
. $PSScriptRoot\.tests.header.ps1
#endregion
try
{
    InModuleScope -ModuleName $script:moduleName {
        #region Test Setup
        $rulesToTest = @(
            @{
                Name                        = 'Accounts: Guest account status'
                Value                       = 'Disabled'
                OrganizationValueRequired   = $false
                OrganizationValueTestString = ''
                CheckContent                = 'Verify the effective setting in Local Group Policy Editor.
                Run "gpedit.msc".

                Navigate to Local Computer Policy -&gt; Computer Configuration -&gt; Windows Settings -&gt; Security Settings -&gt; Local Policies -&gt; Security Options.

                If the value for "Accounts: Guest account status" is not set to "Disabled", this is a finding.'
            },
            @{
                Name                        = 'Accounts: Rename guest account'
                Value                       = 'Guest'
                OrganizationValueRequired   = $true
                OrganizationValueTestString = "{0} -notmatch 'Guest'"
                CheckContent                = 'Verify the effective setting in Local Group Policy Editor.
                Run "gpedit.msc".

                Navigate to Local Computer Policy -&gt; Computer Configuration -&gt; Windows Settings -&gt; Security Settings -&gt; Local Policies -&gt; Security Options.

                If the value for "Accounts: Rename guest account" is not set to a value other than "Guest", this is a finding.'
            },
            @{
                Name                        = 'Network security: Force logoff when logon hours expire'
                Value                       = 'Enabled'
                OrganizationValueRequired   = $false
                OrganizationValueTestString = ''
                CheckContent                = 'Verify the effective setting in Local Group Policy Editor.
                Run "gpedit.msc".

                Navigate to Local Computer Policy -&gt; Computer Configuration -&gt; Windows Settings -&gt; Security Settings -&gt; Local Policies -&gt; Security Options.

                If the value for "Network security: Force logoff when logon hours expire" is not set to "Enabled", this is a finding.'
            },
            @{
                Name                        = 'System cryptography: Use FIPS-compliant algorithms for encryption, hashing, and signing'
                Value                       = 'Enabled'
                OrganizationValueRequired   = $false
                OrganizationValueTestString = ''
                CheckContent                = 'Review system configuration to determine whether FIPS 140-2 support has been enabled
                # Modification for SQL Server 2016 Instance SecurityPolicyDSC rule type conversion
                Run gpedit.msc.
                Start >> Control Panel >> Administrative Tools >> Local Security Policy >> Local Policies >> Security Options
                If the value for "System cryptography: Use FIPS-compliant algorithms for encryption, hashing, and signing" is not set to "Enabled", this is a finding.'
            }
        )

        $stigRule = Get-TestStigRule -CheckContent $rulesToTest[0].CheckContent -ReturnGroupOnly
        $rule = [SecurityOptionRule]::new( $stigRule )
        #endregion
        #region Class Tests
        Describe "$($rule.GetType().Name) Child Class" {

            Context 'Base Class' {

                It 'Shoud have a BaseType of STIG' {
                    $rule.GetType().BaseType.ToString() | Should Be 'Rule'
                }
            }

            Context 'Class Properties' {

                $classProperties = @('OptionName', 'OptionValue')

                foreach ( $property in $classProperties )
                {
                    It "Should have a property named '$property'" {
                        ( $rule | Get-Member -Name $property ).Name | Should Be $property
                    }
                }
            }
        }
        #endregion
        #region Method Tests
        Describe 'Get-SecurityOptionName' {

            foreach ( $string in $rulesToTest )
            {
                It "Should return '$($string.Name)'" {
                    $checkContent = Split-TestStrings -CheckContent $string.CheckContent
                    Get-SecurityOptionName -CheckContent $checkContent | Should Be $string.Name
                }
            }
        }

        Describe 'Get-SecurityOptionValue' {

            foreach ( $string in $rulesToTest )
            {
                It "Should return '$($string.Value)'" {
                    $checkContent = Split-TestStrings -CheckContent $string.CheckContent
                    Get-SecurityOptionValue -CheckContent $checkContent | Should Be $string.Value
                }
            }
        }
        #endregion
        #region Data Tests

        #endregion
    }
}
finally
{
    . $PSScriptRoot\.tests.footer.ps1
}
