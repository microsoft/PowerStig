#region Header
. $PSScriptRoot\.tests.header.ps1
#endregion
try
{
    #region Test Setup
    $testStrings = @(
        @{
            FeatureName  = 'SMB1Protocol'
            InstallState = 'Absent'
            OrganizationValueRequired = $false
            CheckContent = 'This applies to Windows 2012 R2.

            Run "Windows PowerShell" with elevated privileges (run as administrator).
            Enter the following:
            Get-WindowsOptionalFeature -Online | Where FeatureName -eq SMB1Protocol

            If "State : Enabled" is returned, this is a finding.

            Alternately:
            Search for "Features".
            Select "Turn Windows features on or off".

            If "SMB 1.0/CIFS File Sharing Support" is selected, this is a finding.'
        }
        @{
            FeatureName  = 'Powershell-v2'
            InstallState = 'Absent'
            OrganizationValueRequired = $false
            CheckContent = 'Windows PowerShell 2.0 is not installed by default.

            Open "Windows PowerShell".

            Enter "Get-WindowsFeature -Name PowerShell-v2".

            If "Installed State" is "Installed", this is a finding.

            An Installed State of "Available" or "Removed" is not a finding.'
        }
    )
    #endregion
    #region Tests
    Describe 'Windows Feature Conversion' {

        foreach ( $testString in $testStrings )
        {
            [xml] $stigRule = Get-TestStigRule -CheckContent $testString.CheckContent -XccdfTitle Windows
            $TestFile = Join-Path -Path $TestDrive -ChildPath 'TextData.xml'
            $stigRule.Save( $TestFile )
            $rule = ConvertFrom-StigXccdf -Path $TestFile

            It 'Should return an WindowsFeatureRule Object' {
                $rule.GetType() | Should Be 'WindowsFeatureRule'
            }
            It "Should set Feature Name to '$($testString.FeatureName)'" {
                $rule.FeatureName | Should Be $testString.FeatureName
            }
            It "Should set Install State to '$($testString.InstallState)'" {
                $rule.InstallState | Should Be $testString.InstallState
            }
            It "Should set OrganizationValueRequired to $($testString.OrganizationValueRequired)" {
                $rule.OrganizationValueRequired | Should Be $testString.OrganizationValueRequired
            }
            It "Should set OrganizationValueTestString to $($testString.OrganizationValueTestString)" {
                $rule.OrganizationValueTestString | Should Be $testString.OrganizationValueTestString
            }
            It 'Should set the correct DscResource' {
                $rule.DscResource | Should Be 'WindowsOptionalFeature'
            }
            It 'Should Set the status to pass' {
                $rule.conversionstatus | Should Be 'pass'
            }
        }
    }
    #endregion
}
finally
{
    . $PSScriptRoot\.tests.footer.ps1
}
