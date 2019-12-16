#region Header
# Convert Class Private functions Header V1
$script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$script:moduleName = 'PowerStig'
$script:modulePath = "$($script:moduleRoot)\$($script:moduleName).psd1"
$script:dscCompositePath = Join-Path -Path $script:moduleRoot -ChildPath 'DSCResources'

Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath 'Tools\TestHelper\TestHelper.psm1') -Force
Import-Module $modulePath -Force
#endregion

Describe "$moduleName module" {

    It 'Should be a Script Module' {
        (Get-Module -Name $script:modulePath -ListAvailable).ModuleType | Should Be 'Script'
    }

    $compositeModulePaths = (Get-ChildItem -Path  $script:dscCompositePath -Include '*schema.psm1' -Recurse).FullName
    $manifestRequiredModules = (Import-PowerShellDataFile -Path $script:modulePath).RequiredModules |
        ForEach-Object -Process {[pscustomobject]$PSItem}

    foreach ($compositeModule in $compositeModulePaths)
    {
        $dscModuleInfo = Get-DscResourceModuleInfo -Path $compositeModule
        $dscCompositeFile = $compositeModule | Split-Path -Leaf

        foreach ($moduleInfo in $dscModuleInfo)
        {
            $moduleData = $manifestRequiredModules | Where-Object -FilterScript {$PSItem.ModuleName -eq $moduleInfo.ModuleName}

            It "Should require the same module listed in the manifest for DscResource $dscCompositeFile Module: $($moduleInfo.ModuleName)" {
                $moduleInfo.ModuleVersion | Should -Be $moduleData.ModuleVersion
            }
        }
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
