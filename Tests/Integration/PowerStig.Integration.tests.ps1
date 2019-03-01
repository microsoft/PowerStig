#region Header
# Convert Class Private functions Header V1
$script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$script:moduleName = 'PowerStig'
$script:modulePath = "$($script:moduleRoot)\$($script:moduleName).psd1"

Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath 'Tools\TestHelper\TestHelper.psm1') -Force
Import-Module $modulePath -Force
#endregion

Describe "$moduleName module" {

    It 'Should be a Script Module' {
        (Get-Module -Name $script:modulePath -ListAvailable).ModuleType | Should Be 'Script'
    }

    Context 'Exported Commands' {

        $commands = (Get-Command -Module $moduleName).Name
        $exportedCommands = @('Get-DomainName', 'Get-Stig', 'New-StigCheckList')

        foreach ($export in $exportedCommands)
        {
            It "Should export the $export Command" {
                $commands.Contains($export) | Should Be $true
            }
        }

        It 'Should not have more commands than are tested' {
            $compare = Compare-Object -ReferenceObject $commands -DifferenceObject $exportedCommands
            $compare.Count | Should Be 0
        }
    }
}
