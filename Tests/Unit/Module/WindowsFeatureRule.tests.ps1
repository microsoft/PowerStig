#region Header
. $PSScriptRoot\.tests.header.ps1
$setDynamicClassFileParams = @{
    ClassModuleFileName = 'WindowsFeatureRule.Convert.psm1'
    PowerStigBuildPath  = $script:moduleRoot
    DestinationPath     = (Join-Path -Path $PSScriptRoot -ChildPath '..\.DynamicClassImport\WindowsFeatureRule.Convert.ps1')
}
Set-DynamicClassFile @setDynamicClassFileParams
. $setDynamicClassFileParams.DestinationPath
#endregion

try
{
    InModuleScope -ModuleName "$($global:moduleName).Convert" {
        #region Test Setup
        $testRuleList = @(
            @{
                Name = 'Web-DAV-Publishing'
                Ensure = 'Absent'
                OrganizationValueRequired = $false
                CheckContent = 'Open the IIS 8.5 Manager.

                Click the IIS 8.5 web server name.

                Review the features listed under the “IIS" section.

                If the "WebDAV Authoring Rules" icon exists, this is a finding.'
            },
            @{
                Name = 'TelnetClient'
                Ensure = 'Absent'
                OrganizationValueRequired = $false
                CheckContent = 'The "Telnet Client" is not installed by default.  Verify it has not been installed.

                Navigate to the Windows\System32 directory.

                If the "telnet" application exists, this is a finding.'
            },
            @{
                Name = 'SimpleTCP'
                Ensure = 'Absent'
                OrganizationValueRequired = $false
                CheckContent = '"Simple TCP/IP Services" is not installed by default.  Verify it has not been installed.

                Run "Services.msc".

                If "Simple TCP/IP Services" is listed, this is a finding.'
            },
            @{
                Name = 'SMB1Protocol'
                Ensure = 'Absent'
                OrganizationValueRequired = $false
                CheckContent = 'This requirement applies to Windows 2012 R2, it is NA for Windows 2012 (see V-73519 and V-73523 for 2012 requirements).

                Different methods are available to disable SMBv1 on Windows 2012 R2.  This is the preferred method, however if V-73519 and V-73523 are configured, this is NA.

                Run "Windows PowerShell" with elevated privileges (run as administrator).
                Enter the following:
                Get-WindowsOptionalFeature -Online | Where FeatureName -eq SMB1Protocol

                If "State : Enabled" is returned, this is a finding.

                Alternately:
                Search for "Features".
                Select "Turn Windows features on or off".

                If "SMB 1.0/CIFS File Sharing Support" is selected, this is a finding.'
            },
            @{
                Name = 'PowerShell-v2'
                Ensure = 'Absent'
                OrganizationValueRequired = $false
                CheckContent = 'Windows PowerShell 2.0 is not installed by default.

                Open "Windows PowerShell".

                Enter "Get-WindowsFeature -Name PowerShell-v2".

                If "Installed State" is "Installed", this is a finding.

                An Installed State of "Available" or "Removed" is not a finding.'
            },
            @{
                Name = 'Fax'
                Ensure = 'Absent'
                OrganizationValueRequired = $false
                CheckContent = 'Open "PowerShell".

                Enter "Get-WindowsFeature | Where Name -eq Fax".

                If "Installed State" is "Installed", this is a finding.

                An Installed State of "Available" or "Removed" is not a finding.'
            }
        )
        #endregion

        foreach ($testRule in $testRuleList)
        {
            . $PSScriptRoot\Convert.CommonTests.ps1
        }

        #region Add Custom Tests Here
        Describe 'MultipleRules' {
            # TODO move this to the CommonTests
            $testRuleList = @(
                @{
                    Count = 2
                    CheckContent = 'IIS is not installed by default.  Verify it has not been installed on the system.

                    Run "Programs and Features".
                    Select "Turn Windows features on or off".

                    If the entries for "Internet Information Services" or "Internet Information Services Hostable Web Core" are selected, this is a finding.

                    If an application requires IIS or a subset to be installed to function, this needs be documented with the ISSO.  In addition, any applicable requirements from the IIS STIG must be addressed.'
                }
            )
            foreach ($testRule in $testRuleList)
            {
                # Get the rule element with the checkContent injected into it
                $stigRule = Get-TestStigRule -CheckContent $testRule.CheckContent -ReturnGroupOnly
                # Create an instance of the convert class that is currently being tested
                $convertedRule = [WindowsFeatureRuleConvert]::new($stigRule)
                It "Should return $true" {
                    $convertedRule.HasMultipleRules() | Should Be $true
                }
                It "Should return $($testRule.Count) rules" {
                    $multipleRule = $convertedRule.SplitMultipleRules()
                    $multipleRule.count | Should Be $testRule.Count
                }
            }
        }
        #endregion
    }
}
finally
{
    . $PSScriptRoot\.tests.footer.ps1
}
