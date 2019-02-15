using module .\..\..\..\Module\Rule.AccountPolicy\Convert\AccountPolicyRule.Convert.psm1
#region Header
. $PSScriptRoot\.tests.header.ps1
#endregion
try
{
    InModuleScope -ModuleName "$($script:moduleName).Convert" {
        #region Test Setup
        $testRuleList = @(
            @{
                PolicyName = 'Account lockout duration'
                PolicyValue = $null
                OrganizationValueRequired = $true
                OrganizationValueTestString = "'{0}' -ge '15' -or '{0}' -eq '0'"
                CheckContent = 'Verify the effective setting in Local Group Policy Editor.
                Run "gpedit.msc".

                Navigate to Local Computer Policy &gt;&gt; Computer Configuration &gt;&gt; Windows Settings &gt;&gt; Security Settings &gt;&gt; Account Policies &gt;&gt; Account Lockout
                Policy.

                If the "Account lockout duration" is less than "15" minutes (excluding "0"), this is a finding.'
            },
            @{
                PolicyName = 'Password must meet complexity requirements'
                PolicyValue = 'Enabled'
                OrganizationValueRequired = $false
                CheckContent = 'Verify the effective setting in Local Group Policy Editor.
                Run "gpedit.msc".

                Navigate to Local Computer Policy &gt;&gt; Computer Configuration &gt;&gt; Windows Settings &gt;&gt; Security Settings &gt;&gt; Account Policies &gt;&gt; Password Policy.

                If the value for "Password must meet complexity requirements" is not set to "Enabled", this is a finding.

                If the site is using a password filter that requires this setting be set to "Disabled" for the filter to be used, this would not be considered a finding.'
            },
            @{
                PolicyName = 'Store passwords using reversible encryption'
                PolicyValue = 'Disabled'
                OrganizationValueRequired = $false
                CheckContent = 'Verify the effective setting in Local Group Policy Editor.
                Run "gpedit.msc".

                Navigate to Local Computer Policy &gt;&gt; Computer Configuration &gt;&gt; Windows Settings &gt;&gt; Security Settings &gt;&gt; Account Policies &gt;&gt; Password Policy.

                If the value for "Store passwords using reversible encryption" is not set to "Disabled", this is a finding.'
            },
            @{
                PolicyName = 'Minimum password length'
                PolicyValue = $null
                OrganizationValueRequired = $true
                OrganizationValueTestString = "'{0}' -ge '14'"
                CheckContent = 'Verify the effective setting in Local Group Policy Editor.
                Run "gpedit.msc".

                Navigate to Local Computer Policy -&gt; Computer Configuration -&gt; Windows Settings -&gt; Security Settings -&gt; Account Policies -&gt; Password Policy.

                If the value for the "Minimum password length" is less than "14" characters, this is a finding.'
            },
            @{
                PolicyName = 'Enforce user logon restrictions'
                PolicyValue = 'Enabled'
                OrganizationValueRequired = $false
                CheckContent = 'Verify the following is configured in the Default Domain Policy.

                Open "Group Policy Management".
                Navigate to "Group Policy Objects" in the Domain being reviewed (Forest &gt; Domains &gt; Domain).
                Right click on the "Default Domain Policy".
                Select Edit.
                Navigate to Computer Configuration &gt; Policies &gt; Windows Settings &gt; Security Settings &gt; Account Policies &gt; Kerberos Policy.

                If the "Enforce user logon restrictions" is not set to "Enabled", this is a finding.'
            }
        )
        #endregion
        Foreach ($testRule in $testRuleList)
        {
            . .\Convert.CommonTests.ps1
        }

        #region Add Custom Tests Here

        #endregion
    }
}
finally
{
    . $PSScriptRoot\.tests.footer.ps1
}
