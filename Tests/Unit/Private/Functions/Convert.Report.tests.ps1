#region HEADER
$script:moduleRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)))
$script:moduleName = $MyInvocation.MyCommand.Name -replace '\.tests\.ps1', '.ps1'
$script:modulePath = "$($script:moduleRoot)$(($PSScriptRoot -split 'Unit')[1])\$script:moduleName"
if ( (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'PowerStig.Tests'))) -or `
     (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'PowerStig.Tests\TestHelper.psm1'))) )
{
    & git @('clone','https://github.com/Microsoft/PowerStig.Tests',(Join-Path -Path $script:moduleRoot -ChildPath 'PowerStig.Tests'))
}
Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'PowerStig.Tests' -ChildPath 'TestHelper.psm1')) -Force
Import-Module $modulePath -Force
#endregion


Describe "Get-RuleTypeList" {

    It "Should exist" {
        Get-Command Get-RuleTypeList | Should Not BeNullOrEmpty
    }

    $Global:stigSettings = @(
        @{
            id       = 'V-1000'
            RuleType = 'RegistryRule'
        },
        @{
            id       = 'V-1001'
            RuleType = 'RegistryRule'
        },
        @{
            id       = 'V-1002'
            RuleType = 'AuditPolicyRule'
        }
    )

    It "Should return alphabetical list of STIG Types " {
        #(Get-RuleTypeList -StigSettings $Global:stigSettings)[0] | Should Be "AuditPolicyRule"
        #(Get-RuleTypeList -StigSettings $Global:stigSettings)[1] | Should Be "RegistryRule"
    }
}
