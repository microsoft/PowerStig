# Integration test header
if ((Get-PSCallStack)[1].Command -eq 'PowerStig.Integration.tests.ps1')
{
    $script:moduleName = 'PowerStig'
    $extension = 'psd1'
}
else
{
    $script:moduleName = 'PowerStig.Convert'
    $extension = 'psm1'
}

$script:projectRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$script:buildOutput = Join-Path -Path $projectRoot -ChildPath 'output'
$script:modulePath = (Get-ChildItem -Path $buildOutput -Filter ('{0}.{1}' -f $script:moduleName, $extension) -Recurse).FullName
$script:moduleRoot = Split-Path -Path $script:modulePath -Parent
$script:dscCompositePath = Join-Path -Path $script:moduleRoot -ChildPath 'DSCResources'
$helperModulePath = Join-Path -Path $script:projectRoot -ChildPath 'Tools\TestHelper\TestHelper.psm1'

Import-Module $helperModulePath -Force
Import-Module $script:modulePath -Force
