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

    #region Integration Tests

    foreach ($stig in $stigList)
    {
        [xml] $dscXml = Get-Content -Path $stig.Path

        $technologyConfig = "$($script:DSCCompositeResourceName)_config"

        $skipRule = Get-Random -InputObject $dscXml.DISASTIG.DnsServerSettingRule.Rule.id
        $skipRuleType = "PermissionRule"
        $expectedSkipRuleTypeCount = $dscXml.DISASTIG.PermissionRule.ChildNodes.Count

        $skipRuleMultiple = Get-Random -InputObject $dscXml.DISASTIG.DnsServerSettingRule.Rule.id -Count 2
        $skipRuleTypeMultiple = @('PermissionRule','UserRightRule')
        $expectedSkipRuleTypeMultipleCount = $dscXml.DISASTIG.PermissionRule.ChildNodes.Count + $dscXml.DISASTIG.UserRightRule.ChildNodes.Count

        $exception = Get-Random -InputObject $dscXml.DISASTIG.DnsServerSettingRule.Rule.id
        $exceptionMultiple = Get-Random -InputObject $dscXml.DISASTIG.DnsServerSettingRule.Rule.id -Count 2

        $userSettingsPath = "$PSScriptRoot\Common.integration.ps1"
        . $userSettingsPath
    }
    #endregion Tests
}
finally
{
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
}
