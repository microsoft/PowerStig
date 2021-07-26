# Unit Test Header
$script:projectRoot = Split-Path -Path (Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent) -Parent
$script:buildOutput = Join-Path -Path $script:projectRoot -ChildPath 'output'
$script:manifestPath = (Get-ChildItem -Path $script:buildOutput -Filter 'PowerStig.psd1' -Recurse)
$script:moduleRoot = Split-Path -Path ($script:manifestPath).FullName -Parent
$psStackCommand = (Get-PSCallStack)[1].Command -replace '\.tests\.ps1'
if ($psStackCommand -ne 'Convert.CommonTests.ps1')
{
    $global:moduleName = $psStackCommand
    $script:modulePath = "$($script:moduleRoot)$(($PSScriptRoot -split 'Unit')[1])\$global:moduleName\$($global:moduleName).psm1"
}

Import-Module -Name (Join-Path -Path $script:projectRoot -ChildPath 'Tools\TestHelper\TestHelper.psm1') -Force -Global

<#
    if the \.DynamicClassImport folder does not exist create it. This folder is used to import class based
    modules specific to a PowerSTIG build version. The challenge is the 'using module' statement will not
    allow variables to be passed to it. The output/PowerSTIG folder will have a new version of the build after
    the build script is executed, i.e.: .\output\PowerSTIG\4.4.0\<module files>. Therefore the using statement
    has to be dynamically created with a static path and loaded via dot sourcing.
#>
$dynamicClassImportPath = Join-Path -Path $PSScriptRoot -ChildPath '..\.DynamicClassImport'
if ((Test-Path -Path $dynamicClassImportPath) -eq $false)
{
    New-Item -Path $dynamicClassImportPath -ItemType Directory
}

$setDynamicClassFileParams = @{
    PowerStigBuildPath  = $script:moduleRoot
}

switch ($psStackCommand)
{
    'Common'
    {
        $destinationPath = Join-Path -Path $PSScriptRoot -ChildPath '..\.DynamicClassImport\Common.ps1'
        [void] $setDynamicClassFileParams.Add('DestinationPath', $destinationPath)
        [void] $setDynamicClassFileParams.Add('ClassModuleFileName', 'Common.psm1')
    }

    'Convert.CommonTests.ps1'
    {
        $destinationPath = Join-Path -Path $PSScriptRoot -ChildPath '..\.DynamicClassImport\Rule.ps1'
        [void] $setDynamicClassFileParams.Add('DestinationPath', $destinationPath)
        [void] $setDynamicClassFileParams.Add('ClassModuleFileName', 'Rule.psm1')
    }

    'HardCodedRule'
    {
        $destinationPath = Join-Path -Path $PSScriptRoot -ChildPath '..\.DynamicClassImport\ConvertFactory.ps1'
        [void] $setDynamicClassFileParams.Add('DestinationPath', $destinationPath)
        [void] $setDynamicClassFileParams.Add('ClassModuleFileName', 'ConvertFactory.psm1')
    }

    'Rule'
    {
        $destinationPath = Join-Path -Path $PSScriptRoot -ChildPath '..\.DynamicClassImport\Rule.ps1'
        [void] $setDynamicClassFileParams.Add('DestinationPath', $destinationPath)
        [void] $setDynamicClassFileParams.Add('ClassModuleFileName', @('Rule.psm1', 'ConvertFactory.psm1'))
    }

    'STIG.Checklist'
    {
        $functionCheckListFile = Join-Path -Path $script:moduleRoot -ChildPath '\Module\STIG\Functions.Checklist.ps1'
        . $functionCheckListFile
    }

    'STIG.DomainName'
    {
        $functionDomainName = Join-Path -Path $script:moduleRoot -ChildPath '\Module\STIG\Functions.DomainName.ps1'
        . $functionDomainName
    }

    'STIG.RuleQuery'
    {
        $functionRuleQuery = Join-Path -Path $script:moduleRoot -ChildPath '\Module\STIG\Functions.RuleQuery.ps1'
        . $functionRuleQuery
    }

    'STIG.PowerStigXml'
    {
        $functionPowerStigXml = Join-Path -Path $script:moduleRoot -ChildPath '\Module\STIG\Convert\Functions.PowerStigXml.ps1'
        . $functionPowerStigXml
        $functionReport = Join-Path -Path $script:moduleRoot -ChildPath '\Module\STIG\Convert\Functions.Report.ps1'
        . $functionReport
        $dscResourceData = Join-Path -Path $script:moduleRoot -ChildPath '\Module\STIG\Convert\Data.ps1'
        . $dscResourceData
        $destinationPath = Join-Path -Path $PSScriptRoot -ChildPath '..\.DynamicClassImport\Rule.ps1'
        [void] $setDynamicClassFileParams.Add('DestinationPath', $destinationPath)
        [void] $setDynamicClassFileParams.Add('ClassModuleFileName', @('Rule.psm1', 'ConvertFactory.psm1','DocumentRule.Convert.psm1','Stig.psm1'))
    }

    'STIG.BackupRevert'
    {
        $functionCheckListFile = Join-Path -Path $script:moduleRoot -ChildPath '\Module\STIG\Functions.Checklist.ps1'
        . $functionCheckListFile
    }

    'STIG'
    {
        $destinationPath = Join-Path -Path $PSScriptRoot -ChildPath '..\.DynamicClassImport\Convert.Main.ps1'
        [void] $setDynamicClassFileParams.Add('DestinationPath', $destinationPath)
        [void] $setDynamicClassFileParams.Add('ClassModuleFileName', 'Convert.Main.psm1')
    }

    default
    {
        $ruleFile = '{0}.Convert' -f $PSItem
        $destinationPath = Join-Path -Path $PSScriptRoot -ChildPath ('..\.DynamicClassImport\{0}.ps1' -f $ruleFile)
        [void] $setDynamicClassFileParams.Add('DestinationPath', $destinationPath)
        [void] $setDynamicClassFileParams.Add('ClassModuleFileName', ('{0}.psm1' -f $ruleFile))
    }
}

if
(
    $global:moduleName -notmatch 'STIG.(Checklist|DomainName|RuleQuery)'
)
{
    Set-DynamicClassFile @setDynamicClassFileParams
    . $setDynamicClassFileParams.DestinationPath
}
else
{
    $commonModulePath = Join-Path -Path $script:moduleRoot -ChildPath 'Module\Common\Common.psm1'
    Import-Module -Name $commonModulePath
}

<#
    Several classes check for duplicate rules against a global variable stigSettings.
    During unit testing, this variable is not created, so it needs to be created before
    the unit tests can run successfully.
#>
[System.Collections.ArrayList] $global:stigSettings = @()
$global:StigRuleGlobal = @{ID = 'V-1000'}
