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
        [xml] $dscXml = Get-Content -Path $stig.Path

        $skipRule = Get-Random -InputObject $dscXml.DISASTIG.MimeTypeRule.Rule.id
        $skipRuleType = "IisLoggingRule"
        $expectedSkipRuleTypeCount = $dscXml.DISASTIG.IisLoggingRule.ChildNodes.Count

        $skipRuleMultiple = Get-Random -InputObject $dscXml.DISASTIG.WebConfigurationPropertyRule.Rule.id -Count 2
        $skipRuleTypeMultiple = @('MimeTypeRule','IisLoggingRule')
        $expectedSkipRuleTypeMultipleCount = $dscXml.DISASTIG.MimeTypeRule.ChildNodes.Count + $dscXml.DISASTIG.IisLoggingRule.ChildNodes.Count

        $exception = Get-Random -InputObject $dscXml.DISASTIG.WebConfigurationPropertyRule.Rule.id
        $exceptionMultiple = Get-Random -InputObject $dscXml.DISASTIG.WebConfigurationPropertyRule.Rule.id -Count 2

        $userSettingsPath = "$PSScriptRoot\Common.integration.ps1"
        . $userSettingsPath
    }
}
#endregion Tests
finally
{
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
}
