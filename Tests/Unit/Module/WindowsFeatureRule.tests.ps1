#region Header
using module .\..\..\..\Module\Rule.WindowsFeature\Convert\WindowsFeatureRule.Convert.psm1
. $PSScriptRoot\.tests.header.ps1
#endregion
try
{
    InModuleScope -ModuleName "$($global:moduleName).Convert" {
        #region Test Setup
        $testRuleList = @(
            @{
                FeatureName = 'Web-DAV-Publishing'
                InstallState = 'Absent'
                OrganizationValueRequired = $false
                CheckContent = 'Open the IIS 8.5 Manager.

                Click the IIS 8.5 web server name.

                Review the features listed under the “IIS" section.

                If the "WebDAV Authoring Rules" icon exists, this is a finding.'
            },
            @{
                FeatureName = 'TelnetClient'
                InstallState = 'Absent'
                OrganizationValueRequired = $false
                CheckContent = 'The "Telnet Client" is not installed by default.  Verify it has not been installed.

                Navigate to the Windows\System32 directory.

                If the "telnet" application exists, this is a finding.'
            },
            @{
                FeatureName = 'SimpleTCP'
                InstallState = 'Absent'
                OrganizationValueRequired = $false
                CheckContent = '"Simple TCP/IP Services" is not installed by default.  Verify it has not been installed.

                Run "Services.msc".

                If "Simple TCP/IP Services" is listed, this is a finding.'
            },
            @{
                FeatureName = 'IIS-HostableWebCore,IIS-WebServer'
                InstallState = 'Absent'
                OrganizationValueRequired = $false
                CheckContent = 'IIS is not installed by default.  Verify it has not been installed on the system.

                Run "Programs and Features".
                Select "Turn Windows features on or off".

                If the entries for "Internet Information Services" or "Internet Information Services Hostable Web Core" are selected, this is a finding.

                If an application requires IIS or a subset to be installed to function, this needs be documented with the ISSO.  In addition, any applicable requirements from the IIS STIG must be addressed.'
            },
            @{
                FeatureName = 'SMB1Protocol'
                InstallState = 'Absent'
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
                FeatureName = 'PowerShell-v2'
                InstallState = 'Absent'
                OrganizationValueRequired = $false
                CheckContent = 'Windows PowerShell 2.0 is not installed by default.

                Open "Windows PowerShell".

                Enter "Get-WindowsFeature -Name PowerShell-v2".

                If "Installed State" is "Installed", this is a finding.

                An Installed State of "Available" or "Removed" is not a finding.'
            },
            @{
                FeatureName = 'Fax'
                InstallState = 'Absent'
                OrganizationValueRequired = $false
                CheckContent = 'Open "PowerShell".

                Enter "Get-WindowsFeature | Where Name -eq Fax".

                If "Installed State" is "Installed", this is a finding.

                An Installed State of "Available" or "Removed" is not a finding.'
            }
        )
        #endregion

        Foreach ($testRule in $testRuleList)
        {
            . $PSScriptRoot\Convert.CommonTests.ps1
        }

        #region Add Custom Tests Here

        #endregion


    # InModuleScope -ModuleName "$($script:moduleName).Convert" {
    #     #region Test Setup
    #     $stigRule = Get-TestStigRule -ReturnGroupOnly
    #     $rule = [WindowsFeatureRuleConvert]::new( $stigRule )
    #     #endregion
    #     #region Class Tests
    #     Describe "$($rule.GetType().Name) Child Class" {

    #         Context 'Base Class' {

    #             It 'Shoud have a BaseType of Rule' {
    #                 $rule.GetType().BaseType.ToString() | Should Be 'WindowsFeatureRule'
    #             }
    #         }

    #         Context 'Class Properties' {

    #             $classProperties = @('FeatureName', 'InstallState')

    #             foreach ( $property in $classProperties )
    #             {
    #                 It "Should have a property named '$property'" {
    #                     ( $rule | Get-Member -Name $property ).Name | Should Be $property
    #                 }
    #             }
    #         }
    #     }
    #     #endregion
    #     #region Method Tests

    #     #endregion
    #     #region Data Tests

    #     #endregion
    }
}
finally
{
    . $PSScriptRoot\.tests.footer.ps1
}
