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

        $skipRule = Get-Random -InputObject $powerstigXml.DISASTIG.MimeTypeRule.Rule.id
        $skipRuleType = "IisLoggingRule"
        $expectedSkipRuleTypeCount = $powerstigXml.DISASTIG.IisLoggingRule.ChildNodes.Count

        $skipRuleMultiple = Get-Random -InputObject $powerstigXml.DISASTIG.WebConfigurationPropertyRule.Rule.id -Count 2
        $skipRuleTypeMultiple = @('MimeTypeRule','IisLoggingRule')
        $expectedSkipRuleTypeMultipleCount = $powerstigXml.DISASTIG.MimeTypeRule.ChildNodes.Count + $powerstigXml.DISASTIG.IisLoggingRule.ChildNodes.Count

        $exception = Get-Random -InputObject $powerstigXml.DISASTIG.WebConfigurationPropertyRule.Rule.id
        $exceptionMultiple = Get-Random -InputObject $powerstigXml.DISASTIG.WebConfigurationPropertyRule.Rule.id -Count 2

        $commonIntegrationTests = "$PSScriptRoot\Common.integration.ps1"
        . $commonIntegrationTests
    }
}
finally
{
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
}
