# Integration test header
$script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$script:moduleName = 'PowerStig.Convert'
$script:modulePath = "$($script:moduleRoot)\$($script:moduleName).psm1"

$helperModulePath = Join-Path -Path $script:moduleRoot -ChildPath 'Tools\TestHelper\TestHelper.psm1'
Import-Module $helperModulePath -Force
Import-Module $modulePath -Force
