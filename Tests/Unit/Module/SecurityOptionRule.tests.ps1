#region Header
using module .\..\..\..\Module\Rule.SecurityOption\Convert\SecurityOptionRule.Convert.psm1
. $PSScriptRoot\.tests.header.ps1
#endregion
try
{
    InModuleScope -ModuleName "$($script:moduleName).Convert" {
        #region Test Setup
        $rulesToTest = @(
            @{
                OptionName = 'Accounts: Guest account status'
                OptionValue = 'Disabled'
                OrganizationValueRequired = $false
                OrganizationValueTestString = $null
                CheckContent = 'Verify the effective setting in Local Group Policy Editor.
                Run "gpedit.msc".

                Navigate to Local Computer Policy -&gt; Computer Configuration -&gt; Windows Settings -&gt; Security Settings -&gt; Local Policies -&gt; Security Options.

                If the value for "Accounts: Guest account status" is not set to "Disabled", this is a finding.'
            },
            @{
                OptionName = 'Accounts: Rename guest account'
                OptionValue = $null
                OrganizationValueRequired = $true
                OrganizationValueTestString = "'{0}' -ne 'Guest'"
                CheckContent = 'Verify the effective setting in Local Group Policy Editor.
                Run "gpedit.msc".

                Navigate to Local Computer Policy -&gt; Computer Configuration -&gt; Windows Settings -&gt; Security Settings -&gt; Local Policies -&gt; Security Options.

                If the value for "Accounts: Rename guest account" is not set to a value other than "Guest", this is a finding.'
            },
            @{
                OptionName = 'Network security: Force logoff when logon hours expire'
                OptionValue = 'Enabled'
                OrganizationValueRequired = $false
                OrganizationValueTestString = $null
                CheckContent = 'Verify the effective setting in Local Group Policy Editor.
                Run "gpedit.msc".

                Navigate to Local Computer Policy -&gt; Computer Configuration -&gt; Windows Settings -&gt; Security Settings -&gt; Local Policies -&gt; Security Options.

                If the value for "Network security: Force logoff when logon hours expire" is not set to "Enabled", this is a finding.'
            },
            @{
                OptionName = 'System cryptography: Use FIPS-compliant algorithms for encryption, hashing, and signing'
                OptionValue = 'Enabled'
                OrganizationValueRequired = $false
                OrganizationValueTestString = $null
                CheckContent = 'Review system configuration to determine whether FIPS 140-2 support has been enabled.

                Start &gt;&gt; Control Panel &gt;&gt; Administrative Tools &gt;&gt; Local Security Policy &gt;&gt; Local Policies &gt;&gt; Security Options

                Ensure that "System cryptography: Use FIPS-compliant algorithms for encryption, hashing, and signing" is enabled.

                If "System cryptography: Use FIPS-compliant algorithms for encryption, hashing, and signing" is not "enabled", this is a finding.'
            }
        )
        #endregion

        [int]$count = 0
        Foreach ($rule in $rulesToTest)
        {
            $stigRule = Get-TestStigRule -CheckContent $rule.checkContent -ReturnGroupOnly
            $convertedRule = [SecurityOptionRuleConvert]::new( $stigRule )

            # Only run the base class tests once
            If ($count -le 0)
            {
                Describe "$($convertedRule.GetType().Name) Child Class" {
                    Context 'Base Class' {
                        It 'Shoud have a BaseType of SecurityOptionRule' {
                            $convertedRule.GetType().BaseType.ToString() | Should Be 'SecurityOptionRule'
                        }
                    }

                    Context 'Class Properties' {
                        $classProperties = @('OptionName', 'OptionValue')
                        foreach ( $property in $classProperties )
                        {
                            It "Should have a property named '$property'" {
                                ( $convertedRule | Get-Member -Name $property ).Name | Should Be $property
                            }
                        }
                    }
                }
                $count ++
            }
            Describe 'Class Instance' {
                It "Should return the Option Name" {
                    $convertedRule.OptionName | Should Be $rule.OptionName
                }
                It "Should return the Option Value" {
                    $convertedRule.OptionValue | Should Be $rule.OptionValue
                }
                It "Should return the Organization Value Required flag" {
                    $convertedRule.OrganizationValueRequired | Should Be $rule.OrganizationValueRequired
                }
                It "Should return the correct Organization Value test string" {
                    $convertedRule.OrganizationValueTestString | Should Be $rule.OrganizationValueTestString
                }
            }

            Describe 'Static Match' {
                It 'Should Match the string' {
                    <#
                        When the xccdf xml is loaded, the xml parser decodes html
                        elements. The Match method is expecting decoded strings
                        so to keep the test data consistent with the xccdf xml
                        content it needs to be decoded before testing.
                    #>
                    [SecurityOptionRuleConvert]::Match(
                        [System.Web.HttpUtility]::HtmlDecode( $rule.checkContent )
                    ) | Should Be $true
                }
            }
        }
    }
}
finally
{
    . $PSScriptRoot\.tests.footer.ps1
}
