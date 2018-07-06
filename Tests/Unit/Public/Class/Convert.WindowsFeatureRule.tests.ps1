using module ..\..\..\..\Public\Class\Convert.WindowsFeatureRule.psm1
#region Convert Public Class Header V1
. $PSScriptRoot\.Convert.Test.Header.ps1
#endregion
#region Test Setup
$rule = [WindowsFeatureRule]::new( (Get-TestStigRule -ReturnGroupOnly) )

$windowsFeatureRulesToTest = @(
    @{
        FeatureName  = 'SMB1Protocol'
        InstallState = 'Absent'
        CheckContent = 'This requirement applies to Windows 2012 R2, it is NA for Windows 2012 (see V-73519 and V-73523 for 2012 requirements).

        Different methods are available to disable SMBv1 on Windows 2012 R2. This is the preferred method, however if V-73519 and V-73523 are configured, this is NA.
        
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
        FeatureName  = 'MicrosoftWindowsPowerShellV2,MicrosoftWindowsPowerShellV2Root'
        InstallState = 'Absent'
        CheckContent = 'Run "Windows PowerShell" with elevated privileges (run as administrator).
        Enter the following:
        Get-WindowsOptionalFeature -Online | Where -FeatureName -like *PowerShellv2*

        If either of the following have a "State" of "Enabled", this is a finding.
        FeatureName : MicrosoftWindowsPowerShellV2
        State : Enabled
        FeatureName : MicrosoftWindowsPowerShellV2Root
        State : Enabled

        Alternately:
        Search for "Features".
        Select "Turn Windows features on or off".
        If "Windows PowerShell 2.0" (whether the subcategory of "Windows PowerShell 2.0 Engine" is selected or not) is selected, this is a finding.'
    }
    @{
        FeatureName  = 'SMB1Protocol'
        InstallState = 'Absent'
        CheckContent = ' Different methods are available to disable SMBv1 on Windows 10.  This is the preferred method, however if V-74723 and V-74725 are configured, this is NA.

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
        FeatureName  = 'SNMP'
        InstallState = 'Absent'
        CheckContent = '"SNMP" is not installed by default. Verify it has not been installed.

        Navigate to the Windows\System32 directory.

        If the "SNMP" application exists, this is a finding.'
    }
    @{
        FeatureName  = 'SimpleTCP'
        InstallState = 'Absent'
        CheckContent =  '"Simple TCP/IP Services" is not installed by default.  Verify it has not been installed.

        Run "Services.msc".

        If "Simple TCP/IP Services" is listed, this is a finding.'
    }
)
#endregion
#region Class Tests
Describe "$($rule.GetType().Name) Child Class" {
    
    Context 'Base Class' {
        
        It "Shoud have a BaseType of STIG" {
            $rule.GetType().BaseType.ToString() | Should Be 'STIG'
        }
    }

    Context 'Class Properties' {
        
        $classProperties = @( 'FeatureName', 'InstallState' )

        foreach ( $property in $classProperties )
        {
            It "Should have a property named '$property'" {
                ( $rule | Get-Member -Name $property ).Name | Should Be $property
            }
        }
    }

    Context 'Class Methods' {
        
        $classMethods = @( 'SetFeatureName', 'SetFeatureInstallState' )

        foreach ( $method in $classMethods )
        {
            It "Should have a method named '$method'" {
                ( $rule | Get-Member -Name $method ).Name | Should Be $method
            }
        }

        # If new methods are added this will catch them so test coverage can be added
        It "Should not have more methods than are tested" {
            $memberPlanned = Get-StigBaseMethods -ChildClassMethodNames $classMethods
            $memberActual = ( $rule | Get-Member -MemberType Method ).Name
            $compare = Compare-Object -ReferenceObject $memberActual -DifferenceObject $memberPlanned
            $compare.Count | Should Be 0
        }
    }
}
#endregion
#region Method Function Tests
Describe 'Get-WindowsFeatureName' {

    foreach ( $rule in $windowsFeatureRulesToTest )
    {
        It "Should return '$($rule.FeatureName)'" {
            $result = Get-WindowsFeatureName -CheckContent ($rule.CheckContent )
            $result | Should Be $rule.FeatureName
        } 
    }
}

# Get-FeatureInstallState
Describe 'Get-FeatureInstallState' {
    foreach ( $rule in $windowsFeatureRulesToTest )
    {
        It "Should return '$($rule.InstallState)'" {
            $result = Get-FeatureInstallState -CheckContent ($rule.CheckContent )
            $result | Should Be $rule.InstallState
        } 
    }
}
#endregion
