[string] $sut = $MyInvocation.MyCommand.Path -replace '\\tests\\','\src\' `
-replace '\.tests\.ps1','.ps1' `
-replace '\\unit\\','\'

Import-Module $sut

Describe "Function Get-StigList" {

    It "Should be able to output a table of available STIGs and their associated StigVersion, Technology, TechnologyVersion, and TechnologyRole" {
        Get-StigList | Should Not Be $null
    }
}
