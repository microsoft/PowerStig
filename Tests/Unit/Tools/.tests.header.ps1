# Unit Test Header
$script:moduleSection = Split-Path -Path (Split-Path -Path (Get-PSCallStack)[1].ScriptName -Parent) -Leaf
$script:projectRoot = Split-Path -Path (Split-Path -Path (Split-Path -Path $PSScriptRoot)) -Parent
$script:toolsRoot = Join-Path -Path $script:projectRoot -ChildPath 'Tools'
$script:moduleName = (Get-PSCallStack)[1].Command -replace '\.tests\.ps1', ''
$script:modulePath = "$($script:projectRoot)\$($script:moduleSection)\$script:moduleName\$($script:moduleName).psm1"
$helperModulePath = Join-Path -Path $script:toolsRoot -ChildPath (Join-Path -Path 'TestHelper' -ChildPath 'TestHelper.psm1')

Import-Module -Name $helperModulePath -Force -Global
Import-Module -Name $script:modulePath -Force
