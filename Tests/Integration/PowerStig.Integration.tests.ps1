#region Header
. $PSScriptRoot\.Convert.Integration.Tests.Header.ps1
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
