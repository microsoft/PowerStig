#region Header
. $PSScriptRoot\.tests.Header.ps1
#endregion
try
{
    #region Test Setup
    $checkContent = 'Determine whether any shared accounts exist. If no shared accounts exist, this is NA.

    Shared accounts, such as required by an application, may be approved by the organization.  This must be documented with the ISSO. Documentation must include the reason for the account, who has access to the account, and how the risk of using the shared account is mitigated to include monitoring account activity.
    
    If unapproved shared accounts exist, this is a finding.'
    #endregion
    #region Tests
    Describe 'DocumentRule Conversion' {
        [xml] $stigRule = Get-TestStigRule -CheckContent $checkContent -XccdfTitle 'Windows'
        $TestFile = Join-Path -Path $TestDrive -ChildPath 'TextData.xml'
        $stigRule.Save( $TestFile )
        $rule = ConvertFrom-StigXccdf -Path $TestFile

        It 'Should return an DocumentRule Object' {
            $rule.GetType() | Should Be 'DocumentRule'
        }
        It 'Should set IsNullOrEmpty to false' {
            $rule.IsNullOrEmpty | Should Be $false
        }
        It 'Should set OrganizationValueRequired to false' {
            $rule.OrganizationValueRequired | Should Be $false
        }
        It 'Should set dscresource to "None"' {
            $rule.dscresource | Should Be 'None'
        }
        It 'Should set the Conversion statud to pass ensure value' {
            $rule.conversionstatus | Should Be 'pass'
        }
    }
    #endregion
}
finally
{
    . $PSScriptRoot\.tests.Footer.ps1
}
