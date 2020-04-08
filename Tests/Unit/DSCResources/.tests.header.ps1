# Unit Test Header
$script:dscModuleName = 'PowerStig'
$script:projectRoot = Split-Path -Path (Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent) -Parent
$script:buildOutput = Join-Path -Path $projectRoot -ChildPath 'output'
$script:manifestPath = (Get-ChildItem -Path $buildOutput -Filter 'PowerStig.psd1' -Recurse).FullName
$script:moduleRoot = Split-Path -Path $manifestPath -Parent

Import-Module -Name (Join-Path -Path $projectRoot -ChildPath 'Tools\TestHelper\TestHelper.psm1') -Force
Import-Module -Name (Join-Path -Path $moduleRoot -ChildPath 'DscResources\helper.psm1')
