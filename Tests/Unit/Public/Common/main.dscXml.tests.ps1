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
Import-Module $modulePath
#endregion

# Import the base benchmark xml string data.
$BaseFileContent = Get-Content -Path "$moduleRoot\Tests\Data\sampleXccdf.xml.txt" -Encoding UTF8
Describe "ConvertTo-DscStigXml" {

    It "Should have a synopsis in the help" {
        [string] $Synopsis = (Get-Help ConvertTo-DscStigXml).Synopsis
        $Synopsis | Should Not BeNullOrEmpty
    }

    It 'Should throw an error when given bad xml' {
        #ConvertTo-DscStigXml -   
    }
}
