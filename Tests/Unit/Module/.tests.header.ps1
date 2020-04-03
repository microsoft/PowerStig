# Unit Test Header
$script:projectRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot))
$script:buildOutput = Join-Path -Path $script:projectRoot -ChildPath 'output'
$script:manifestPath = (Get-ChildItem -Path $script:buildOutput -Filter 'PowerStig.psd1' -Recurse)
$script:moduleRoot = Split-Path -Path ($script:manifestPath).FullName -Parent
if ((Get-PSCallStack)[1].Command -ne 'Convert.CommonTests.ps1')
{
    $global:moduleName = (Get-PSCallStack)[1].Command -replace '\.tests\.ps1'
}

$script:modulePath = "$($script:moduleRoot)$(($PSScriptRoot -split 'Unit')[1])\$global:moduleName\$($global:moduleName).psm1"

<#
    if the \.DynamicClassImport folder does not exist create it. This folder is used to import class based
    modules specific to a PowerSTIG build version. The challenge is the 'using module' statement will not
    allow variables to be passed to it. The output/PowerSTIG folder will have a new version of the build after
    the build script is executed, i.e.: .\output\PowerSTIG\4.4.0\<module files>. Therefore the using statement
    has to be statically created and loaded via dot sourcing.
#>
$dynamicClassImportPath = Join-Path -Path $PSScriptRoot -ChildPath '..\.DynamicClassImport'
if ((Test-Path -Path $dynamicClassImportPath) -eq $false)
{
    New-Item -Path $dynamicClassImportPath -ItemType Directory
}

Import-Module -Name (Join-Path -Path $script:projectRoot -ChildPath 'Tools\TestHelper\TestHelper.psm1') -Force -Global

<#
    Several classes check for duplicate rules against a global variable stigSettings.
    During unit testing, this variable is not created, so it needs to be created before
    the unit tests can run successfully.
#>
[System.Collections.ArrayList] $global:stigSettings = @()
$global:StigRuleGlobal = @{ID = 'V-1000'}

