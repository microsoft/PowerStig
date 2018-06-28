$script:ModuleName = $MyInvocation.MyCommand.Name -replace '\.tests',''

#region HEADER
$script:moduleRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot) )
$modulePath = "$($script:moduleRoot)\Common\$ModuleName"
Import-Module (Join-Path -Path $moduleRoot -ChildPath 'Tests\helper.psm1') -Force
Import-Module $modulePath -Force
#endregion

Describe "Function Get-StigList" {

    It "Should be able to output a table of available STIGs and their associated StigVersion, Technology, TechnologyVersion, and TechnologyRole" {
        Get-StigList | Should Not Be $null
    }
}
