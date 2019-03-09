using module .\helper.psm1

$script:DSCCompositeResourceName = ($MyInvocation.MyCommand.Name -split '\.')[0]
. $PSScriptRoot\.tests.header.ps1
# Header

# Using try/finally to always cleanup even if something awful happens.
try
{
    $configFile = Join-Path -Path $PSScriptRoot -ChildPath "$($script:DSCCompositeResourceName).config.ps1"
    . $configFile

    $stigList = Get-StigVersionTable -CompositeResourceName $script:DSCCompositeResourceName

    foreach ($stig in $stigList)
    {
        [xml] $powerstigXml = Get-Content -Path $stig.Path

        $skipRule = Get-Random -InputObject $powerstigXml.DISASTIG.SqlScriptQueryRule.Rule.id
        $skipRuleType = "DocumentRule"
        $expectedSkipRuleTypeCount = $powerstigXml.DISASTIG.DocumentRule.ChildNodes.Count

        $skipRuleMultiple = Get-Random -InputObject $powerstigXml.DISASTIG.DocumentRule.Rule.id -Count 2
        $skipRuleTypeMultiple = $null
        $expectedSkipRuleTypeMultipleCount = 0

        $exception = Get-Random -InputObject $powerstigXml.DISASTIG.SqlScriptQueryRule.Rule.id
        $exceptionMultiple = $null

        $userSettingsPath = "$PSScriptRoot\Common.integration.ps1"
        . $userSettingsPath
    }
}
finally
{
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
}
