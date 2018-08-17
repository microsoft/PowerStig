#region Header
# Convert Class Private functions Header V1
$script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$script:moduleName = 'PowerStig'
$script:modulePath = "$($script:moduleRoot)\$($script:moduleName).psd1"

if ( (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'PowerStig.Tests'))) -or `
    (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'PowerStig.Tests\TestHelper.psm1'))) )
{
    & git @('clone', 'https://github.com/Microsoft/PowerStig.Tests', (Join-Path -Path $script:moduleRoot -ChildPath 'PowerStig.Tests'))
}

Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'PowerStig.Tests' -ChildPath 'TestHelper.psm1')) -Force
Import-Module $modulePath -Force
#endregion

Describe "$ModuleName module" {

    It 'Should be a Script Module' {
        (Get-Module -Name $script:modulePath -ListAvailable).ModuleType | Should Be 'Script'
    }

    Context 'Exported Commands' {

        $commands = (Get-Command -Module $ModuleName).Name
        $exportedCommands = @('Get-OrgSettingsObject', 'Get-DomainName', 'Get-StigList', 'New-StigCheckList')

        foreach ($export in $exportedCommands)
        {
            It "Should export the $export Command" {
                $commands.Contains($export) | Should Be $true
            }
        }

    It "Should not have more commands than are tested" {
            $compare = Compare-Object -ReferenceObject $commands -DifferenceObject $exportedCommands
            $compare.Count | Should Be 0
        }
    }
}
