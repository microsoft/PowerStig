using module .\..\..\..\..\Public\Class\SkippedRuleType.psm1
using module .\..\..\..\..\Public\Enum\StigRuleType.psm1
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
[string[]] $SkippedRuleTypeArray = @(
"AccountPolicyRule",
"AuditPolicyRule",
"RegistryRule",
"SecurityOptionRule",
"ServiceRule",
"UserRightRule"
)
#endregion
#region Class Tests
Describe "SkippedRuleType Class" {

    Context "Constructor" {

        It "Should create an SkippedRuleType class instance using SkippedRuleType1 data" {
            foreach ($type in $SkippedRuleTypeArray)
            {
                $SkippedRuleType = [SkippedRuleType]::new($type)
                $SkippedRuleType.StigRuleType | Should Be $type
            }
        }
    }

    Context "Static Methods" {
        It "ConvertFrom: Should be able to convert an array of SkippedRuleType strings to a SkippedRuleType array" {
            $SkippedRuleTypes = [SkippedRuleType]::ConvertFrom($SkippedRuleTypeArray)

            foreach ($type in $SkippedRuleTypeArray)
            {
                $skippedRuleType = $SkippedRuleTypes.Where( {$_.StigRuleType.ToString() -eq $type})
                $skippedRuleType.StigRuleType | Should Be $type
            }
        }
    }
}
#endregion
