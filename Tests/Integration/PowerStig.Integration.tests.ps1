$script:ModuleName = $MyInvocation.MyCommand.Name -replace '\.Integration\.tests\.ps1', ''

#region HEADER
# Integration Test Template Version: 1.1.1
[String] $script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)

Import-Module (Join-Path -Path $script:moduleRoot -ChildPath 'Tests\helper.psm1' ) -Force
Import-Module (Join-Path -Path $script:moduleRoot -ChildPath "$($script:ModuleName).psd1")
#endregion

Describe "$ModuleName module" {

    Context 'Exported Commands' {

        $commands = (Get-Command -Module $ModuleName).Name
        $exportedCommands = @('Get-OrgSettingsObject', 'Get-DomainName', 'Get-StigList')

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
