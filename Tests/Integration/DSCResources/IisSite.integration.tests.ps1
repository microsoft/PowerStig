using module .\helper.psm1

$script:DSCCompositeResourceName = ($MyInvocation.MyCommand.Name -split '\.')[0]
. $PSScriptRoot\.tests.header.ps1
# Header

# Using try/finally to always cleanup even if something awful happens.
try
{
    #region Integration Tests
    $configFile = Join-Path -Path $PSScriptRoot -ChildPath "$($script:DSCCompositeResourceName).config.ps1"
    . $configFile

    $stigList = Get-StigVersionTable -CompositeResourceName $script:DSCCompositeResourceName

    #region Test Setup
    $WebsiteName = @('WarioSite', 'DKSite')
    $WebAppPool = @('MushroomBeach', 'ToadHarbor')
    #endregionTest Setup

    #region Tests
    foreach ($stig in $stigList)
    {
        [xml] $dscXml = Get-Content -Path $stig.Path

        $technologyConfig = "$($script:DSCCompositeResourceName)_config"

        $skipRule = Get-Random -InputObject $dscXml.DISASTIG.WebConfigurationPropertyRule.Rule.id
        $skipRuleType = "IisLoggingRule"
        $expectedSkipRuleTypeCount = $dscXml.DISASTIG.IisLoggingRule.ChildNodes.Count

        $skipRuleMultiple = Get-Random -InputObject $dscXml.DISASTIG.MimeTypeRule.Rule.id -Count 2
        $skipRuleTypeMultiple = @('WebAppPoolRule','IisLoggingRule')
        $expectedSkipRuleTypeMultipleCount = $dscXml.DISASTIG.WebAppPoolRule.ChildNodes.Count + $dscXml.DISASTIG.IisLoggingRule.ChildNodes.Count

        $exception = Get-Random -InputObject $dscXml.DISASTIG.WebConfigurationPropertyRule.Rule.id
        $exceptionMultiple = Get-Random -InputObject $dscXml.DISASTIG.WebAppPoolRule.Rule.id -Count 2

        $userSettingsPath = "$PSScriptRoot\Common.integration.ps1"
        . $userSettingsPath
    }
    #endregion Tests
}
finally
{
    #region FOOTER
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
    #endregion
}
