
$script:moduleRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot))
$script:moduleName = (Get-PSCallStack)[1].Command -replace '\.tests\.ps1', ''
$script:modulePath = "$($script:moduleRoot)$(($PSScriptRoot -split 'Unit')[1])\$script:moduleName\$($script:moduleName).psm1"

if ( (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'PowerStig.Tests'))) -or `
     (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'PowerStig.Tests\TestHelper.psm1'))) )
{
    & git @('clone', 'https://github.com/Microsoft/PowerStig.Tests', (Join-Path -Path $script:moduleRoot -ChildPath 'PowerStig.Tests'))
}

Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (
                     Join-Path -Path 'PowerStig.Tests'  -ChildPath 'TestHelper.psm1')
                    ) -Force -Global

<#
    Several classes check for duplicate rules against a global variable stigSettings.
    During unit testing, this variable is not created, so it needs to be created before
    the unit tests can run successfully.
#>
[System.Collections.ArrayList] $global:stigSettings = @()
$global:StigRuleGlobal = @{ID = 'V-1000'}
