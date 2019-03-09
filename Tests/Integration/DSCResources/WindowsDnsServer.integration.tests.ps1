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

        $skipRule = Get-Random -InputObject $powerstigXml.DISASTIG.DnsServerSettingRule.Rule.id
        $skipRuleType = "PermissionRule"
        $expectedSkipRuleTypeCount = $powerstigXml.DISASTIG.PermissionRule.ChildNodes.Count

        $skipRuleMultiple = Get-Random -InputObject $powerstigXml.DISASTIG.DnsServerSettingRule.Rule.id -Count 2
        $skipRuleTypeMultiple = @('PermissionRule','UserRightRule')
        $expectedSkipRuleTypeMultipleCount = $powerstigXml.DISASTIG.PermissionRule.ChildNodes.Count + $powerstigXml.DISASTIG.UserRightRule.ChildNodes.Count

        $exception = Get-Random -InputObject $powerstigXml.DISASTIG.DnsServerSettingRule.Rule.id
        $exceptionMultiple = Get-Random -InputObject $powerstigXml.DISASTIG.DnsServerSettingRule.Rule.id -Count 2

        $userSettingsPath = "$PSScriptRoot\Common.integration.ps1"
        . $userSettingsPath
    }
}
finally
{
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
}
