using module .\..\..\..\..\Public\Class\SkippedRule.psm1
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
[string[]] $SkippedRuleArray =
@(
"V-1114",
"V-1115",
"V-3472.a",
"V-4108",
"V-4113",
"V-8322.b",
"V-26482",
"V-26579",
"V-26580",
"V-26581"
)
#endregion
#region Class Tests
Describe "SkippedRule Class" {

    Context "Constructor" {

        It "Should create an SkippedRule class instance using SkippedRule data" {
            foreach ($rule in $SkippedRuleArray) 
            {
                $SkippedRule = [SkippedRule]::new($rule)
                $SkippedRule.StigRuleId | Should Be $rule
            }
        }
    }

    Context "Static Methods" {
        It "ConvertFrom: Should be able to convert an array of StigRuleId strings to a SkippedRule array" {
            $SkippedRules = [SkippedRule]::ConvertFrom($SkippedRuleArray)

            foreach ($rule in $SkippedRuleArray)
            {
                $skippedRule = $SkippedRules.Where( {$_.StigRuleId -eq $rule})
                $skippedRule.StigRuleId | Should Be $rule
            }
        }
    }
}
#endregion
