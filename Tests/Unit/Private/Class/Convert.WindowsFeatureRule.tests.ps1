#region HEADER
. $PSScriptRoot\.Convert.Test.Header.ps1
#endregion
#region Test Setup
$checkContent = 'This applies to Windows 2012 R2.

Run "Windows PowerShell" with elevated privileges (run as administrator).
Enter the following:
Get-WindowsOptionalFeature -Online | Where FeatureName -eq SMB1Protocol

If "State : Enabled" is returned, this is a finding.

Alternately:
Search for "Features".
Select "Turn Windows features on or off".

If "SMB 1.0/CIFS File Sharing Support" is selected, this is a finding.'
#endregion
#region Tests

Describe "ConvertTo-WindowsFeatureRule" {

    $stigRule = Get-TestStigRule -CheckContent $checkContent -ReturnGroupOnly
    $rule = ConvertTo-WindowsFeatureRule -StigRule $stigRule

    It "Should return an WindowsFeatureRule object" {
        $rule.GetType() | Should Be 'WindowsFeatureRule'
    }
}
#endregion
