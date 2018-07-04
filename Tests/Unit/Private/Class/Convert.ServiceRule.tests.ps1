#region HEADER
. $PSScriptRoot\.Convert.Test.Header.ps1
#endregion
#region Test Setup
$checkContent = 'If the server has the role of an FTP server, this is NA.
Run "Services.msc".

If the "Microsoft FTP Service" (Service name: FTPSVC) is installed and not disabled, this is a finding.'
#endregion
#region Tests
try
{
    Describe "ConvertTo-ServiceRule" {
        <#
        This function can't really be unit tested, since the call cannot be mocked by pester, so
        the only thing we can really do at this point is to verify that it returns the correct object.
    #>
        $stigRule = Get-TestStigRule -CheckContent $checkContent -ReturnGroupOnly
        $rule = ConvertTo-ServiceRule -StigRule $stigRule

        It "Should return an ServiceRule object" {
            $rule.GetType() | Should Be 'ServiceRule'
        }
    }
}
catch
{
    Remove-Variable STIGSettings -Scope Global
}
#endregion
