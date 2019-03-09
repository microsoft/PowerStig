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
        [xml] $powerstigXml = Get-Content -Path $stig.Path

        $skipRule = Get-Random -InputObject $powerstigXml.DISASTIG.RegistryRule.Rule.id
        $skipRuleType = "AuditPolicyRule"
        $expectedSkipRuleTypeCount = $powerstigXml.DISASTIG.AuditPolicyRule.ChildNodes.Count

        $skipRuleMultiple = Get-Random -InputObject $powerstigXml.DISASTIG.RegistryRule.Rule.id -Count 2
        $skipRuleTypeMultiple = @('AuditPolicyRule','AccountPolicyRule')
        $expectedSkipRuleTypeMultipleCount = $powerstigXml.DISASTIG.AuditPolicyRule.ChildNodes.Count + $powerstigXml.DISASTIG.AccountPolicyRule.ChildNodes.Count

        $exception = Get-Random -InputObject $powerstigXml.DISASTIG.RegistryRule.Rule.id
        $exceptionMultiple = Get-Random -InputObject $powerstigXml.DISASTIG.RegistryRule.Rule.id -Count 2

        $userSettingsPath = "$PSScriptRoot\Common.integration.ps1"
        . $userSettingsPath
    }
    #endregion Tests
}
finally
{
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
}
