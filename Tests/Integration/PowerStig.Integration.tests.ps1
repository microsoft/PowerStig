#region HEADER
$script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$script:moduleName = $MyInvocation.MyCommand.Name -replace '\.Integration\.tests\.ps1', ''
$script:modulePath = "$($script:moduleRoot)$(($PSScriptRoot -split 'Unit')[1])\$script:moduleName"
if ((-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'PowerStig.Tests'))) -or `
     (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'PowerStig.Tests\TestHelper.psm1'))))
{
    & git @('clone','https://github.com/Microsoft/PowerStig.Tests',(Join-Path -Path $script:moduleRoot -ChildPath 'PowerStig.Tests'))
}
Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'PowerStig.Tests' -ChildPath 'TestHelper.psm1')) -Force
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
