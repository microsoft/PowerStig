#region HEADER
. $PSScriptRoot\.Convert.Test.Header.ps1
#endregion
#region Test Setup
$checkContent = 'Open the Internet Information Services (IIS) Manager.

Click the Application Pools.

Perform for each Application Pool.

Highlight an Application Pool to review and click "Advanced Settings" in the "Actions" pane.

Scroll down to the "Process Model" section and verify the value for "Ping Enabled" is set to "True".

If the value for "Ping Enabled" is not set to "True", this is a finding.'
#endregion
#region Tests
try
{
    Describe "ConvertTo-WebAppPoolRule" {
        $stigRule = Get-TestStigRule -CheckContent $checkContent -ReturnGroupOnly
        $rule = ConvertTo-WebAppPoolRule -StigRule $stigRule

        It "Should return an WebAppPoolRule object" {
            $rule.GetType() | Should Be 'WebAppPoolRule'
        }
    }
}
catch
{
    Remove-Variable STIGSettings -Scope Global
}
#endregion
