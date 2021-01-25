#region Header
. $PSScriptRoot\.tests.header.ps1
#endregion

try
{
    InModuleScope -ModuleName "$($global:moduleName).Convert" {
        #region Test Setup
        $testRuleList = @(
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
            },
            @{
                OptionName = 'Network access: Allow anonymous SID/Name translation'
                OptionValue = 'Disabled'
                OrganizationValueRequired = $false
                OrganizationValueTestString = $null
                CheckContent = 'Verify the effective setting in Local Group Policy Editor.

                Run "gpedit.msc".

                Navigate to Local Computer Policy &gt;&gt; Computer Configuration &gt;&gt; Windows Settings &gt;&gt; Security Settings &gt;&gt; Local Policies &gt;&gt; Security Options.

                If the value for "Network access: Allow anonymous SID/Name translation" is not set to "Disabled", this is a finding.

                For server core installations, run the following command:

                Secedit /Export /Areas SecurityPolicy /CFG C:\Path\FileName.Txt

                If "LSAAnonymousNameLookup" equals "1" in the file, this is a finding.'
            }
        )
        #endregion

        foreach ($testRule in $testRuleList)
        {
            . $PSScriptRoot\Convert.CommonTests.ps1
        }

        #region Add Custom Tests Here

        #endregion
    }
}
finally
{
    . $PSScriptRoot\.tests.footer.ps1
}
