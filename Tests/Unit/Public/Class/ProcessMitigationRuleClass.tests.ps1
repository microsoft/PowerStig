using module ..\..\..\..\Public\Class\ProcessMitigationRuleClass.psm1
#region HEADER
# Convert Public Class Header V1
using module ..\..\..\..\Public\Common\enum.psm1
. $PSScriptRoot\..\..\..\..\Public\Common\data.ps1
$ruleClassName = ($MyInvocation.MyCommand.Name -Split '\.')[0]

$script:moduleRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)))
$script:moduleName = $MyInvocation.MyCommand.Name -replace '\.tests\.ps1', '.psm1'
$script:modulePath = "$($script:moduleRoot)$(($PSScriptRoot -split 'Unit')[1])\$script:moduleName"
if ( (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'PowerStig.Tests'))) -or `
     (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'PowerStig.Tests\TestHelper.psm1'))) )
{
    & git @('clone','https://github.com/Microsoft/PowerStig.Tests',(Join-Path -Path $script:moduleRoot -ChildPath 'PowerStig.Tests'))
}
Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'PowerStig.Tests' -ChildPath 'TestHelper.psm1')) -Force
#endregion
#region Test Setup
$rule = [ProcessMitigationRule]::new( (Get-TestStigRule -ReturnGroupOnly) )

$mitigationsRulesToTest = @(
    @{
        MitigationTarget = 'System'
        Enable           = 'TerminateOnError'
        CheckContent     = ' This is NA prior to v1709 of Windows 10.

        Run "Windows PowerShell" with elevated privileges (run as administrator).

        Enter "Get-ProcessMitigation -System".

        If the status of "Heap: TerminateOnError" is "OFF", this is a finding.

        Values that would not be a finding include:
        ON
        NOTSET'
    }
    @{
        MitigationTarget = 'wordpad.exe'
        Enable           = 'DEP,EnableExportAddressFilter,EnableExportAddressFilterPlus,EnableImportAddressFilter,EnableRopStackPivot,EnableRopCallerCheck,EnableRopSimExec'
        CheckContent     = 'This is NA prior to v1709 of Windows 10.

        Run "Windows PowerShell" with elevated privileges (run as administrator).

        Enter "Get-ProcessMitigation -Name wordpad.exe".
        (Get-ProcessMitigation can be run without the -Name parameter to get a list of all application mitigations configured.)

        If the following mitigations do not have a status of "ON", this is a finding:

        DEP:
        Enable: ON

        Payload:
        EnableExportAddressFilter: ON
        EnableExportAddressFilterPlus: ON
        EnableImportAddressFilter: ON
        EnableRopStackPivot: ON
        EnableRopCallerCheck: ON
        EnableRopSimExec: ON

        The PowerShell command produces a list of mitigations; only those with a required status of "ON" are listed here.'
    }
    @{
        MitigationTarget = 'java.exe,javaw.exe,javaws.exe'
        Enable           = 'DEP,EnableExportAddressFilter,EnableExportAddressFilterPlus,EnableImportAddressFilter,EnableRopStackPivot,EnableRopCallerCheck,EnableRopSimExec'
        CheckContent     = 'This is NA prior to v1709 of Windows 10.

        Run "Windows PowerShell" with elevated privileges (run as administrator).

        Enter "Get-ProcessMitigation -Name [application name]" with each of the following substituted for [application name]:
        java.exe, javaw.exe, and javaws.exe
        (Get-ProcessMitigation can be run without the -Name parameter to get a list of all application mitigations configured.)

        If the following mitigations do not have a status of "ON" for each, this is a finding:

        DEP:
        Enable: ON

        Payload:
        EnableExportAddressFilter: ON
        EnableExportAddressFilterPlus: ON
        EnableImportAddressFilter: ON
        EnableRopStackPivot: ON
        EnableRopCallerCheck: ON
        EnableRopSimExec: ON

        The PowerShell command produces a list of mitigations; only those with a required status of "ON" are listed here.'
    }
    @{
        MitigationTarget = 'System'
        Enable           = 'DEP'
        CheckContent     = 'This is NA prior to v1709 of Windows 10.

        Run "Windows PowerShell" with elevated privileges (run as administrator).

        Enter "Get-ProcessMitigation -System".

        If the status of "DEP: Enable" is "OFF", this is a finding.

        Values that would not be a finding include:
        ON
        NOTSET'
    }
)

#region Class Tests
Describe "$ruleClassName Child Class" {
    
    Context 'Base Class' {
        
        It "Shoud have a BaseType of STIG" {
            $rule.GetType().BaseType.ToString() | Should Be 'STIG'
        }
    }

    Context 'Class Properties' {
        
        $classProperties = @('MitigationTarget', 'Enable', 'Disable')

        foreach ( $property in $classProperties )
        {
            It "Should have a property named '$property'" {
                ( $rule | Get-Member -Name $property ).Name | Should Be $property
            }
        }
    }

    Context 'Class Methods' {
        
        $classMethods = @('SetMitigationTargetName', 'SetMitigationToEnable')

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

# region Method function tests
Describe 'Get-MitigationTargetName' {
    foreach ( $rule in $mitigationsRulesToTest )
    {
        It "Should be a MitigationTarget of '$($rule.MitigationTarget)'" {
            $result = Get-MitigationTargetName -CheckContent $($rule.CheckContent -split '\n')
            $result | Should Be $rule.MitigationTarget
        }
    }
}

Describe 'Get-MitigationPolicyToEnable' {
    Mock -CommandName Test-PoliciesToEnable -MockWith {$true}

    foreach ( $rule in $mitigationsRulesToTest )
    {
        $result = Get-MitigationPolicyToEnable -CheckContent $($rule.CheckContent -split '\n')
        It "Should have Enable equal to: '$($rule.Enable)'" {
            
            $result | Should Be $rule.Enable
        }
    }
}
#endregion
