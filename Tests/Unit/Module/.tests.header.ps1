
$script:moduleRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot))
$global:moduleName = (Get-PSCallStack)[1].Command -replace '\.tests\.ps1', ''
$script:modulePath = "$($script:moduleRoot)$(($PSScriptRoot -split 'Unit')[1])\$script:moduleName\$($script:moduleName).psm1"

Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath 'Tools\TestHelper\TestHelper.psm1') -Force -Global

<#
    Several classes check for duplicate rules against a global variable stigSettings.
    During unit testing, this variable is not created, so it needs to be created before
    the unit tests can run successfully.
#>
[System.Collections.ArrayList] $global:stigSettings = @()
$global:StigRuleGlobal = @{ID = 'V-1000'}
