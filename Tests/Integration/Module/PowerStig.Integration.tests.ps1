#region Header
. $PSScriptRoot\.tests.header.ps1
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
            if ($moduleInfo.ModuleName -ne "Vmware.vSphereDSC")
            {
                It "Should require the same module listed in the manifest for DscResource $dscCompositeFile Module: $($moduleInfo.ModuleName)" {
                    $moduleInfo.ModuleVersion | Should -Be $moduleData.ModuleVersion
                }
            }
        }
    }

    Context 'Exported Commands' {

        $commands = (Get-Command -Module $moduleName).Name
        $exportedCommands = @(
            'Get-DomainName',
            'Get-Stig',
            'New-StigCheckList',
            'Get-StigRuleList',
            'Get-StigVersionNumber',
            'Get-PowerStigFileList',
            'Split-BenchmarkId',
            'Get-StigRule',
            'Get-StigRuleExceptionString',
            'Backup-StigSettings',
            'Restore-StigSettings'
        )

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

    Context 'Import PowerSTIG should not throw' {

        It "Should not throw and error" {
            {Import-Module PowerSTIG} | Should -Not -Throw
        }
    }
}
