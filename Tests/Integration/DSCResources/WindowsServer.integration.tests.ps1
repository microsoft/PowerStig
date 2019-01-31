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

        if ($stig.TechnologyRole -eq 'DNS')
        {
            $exception          = Get-Random -InputObject $dscXml.DISASTIG.UserRightRule.Rule.id
            $exceptionMultiple  = Get-Random -InputObject $dscXml.DISASTIG.UserRightRule.Rule.id -Count 2
            $skipRule           = Get-Random -InputObject $dscXml.DISASTIG.DnsServerRootHintRule.Rule.id
            $skipRuleMultiple   = Get-Random -InputObject $dscXml.DISASTIG.DnsServerRootHintRule.Rule.id -Count 2
            $skipRuleType               = "UserRightRule"
            $expectedSkipRuleTypeCount  = $dscXml.DISASTIG.UserRightRule.ChildNodes.Count
            $skipRuleTypeMultiple               = @('PermissionRule', 'UserRightRule')
            $expectedSkipRuleTypeMultipleCount  = $dscXml.DISASTIG.PermissionRule.ChildNodes.Count + $dscXml.DISASTIG.UserRightRule.ChildNodes.Count
        }
        else
        {
            $exception          = Get-Random -InputObject $dscXml.DISASTIG.RegistryRule.Rule.id
            $exceptionMultiple  = Get-Random -InputObject $dscXml.DISASTIG.RegistryRule.Rule.id -Count 2
            $skipRule           = Get-Random -InputObject $dscXml.DISASTIG.RegistryRule.Rule.id
            $skipRuleMultiple   = Get-Random -InputObject $dscXml.DISASTIG.RegistryRule.Rule.id -Count 2
            $skipRuleType               = "AuditPolicyRule"
            $expectedSkipRuleTypeCount  = $dscXml.DISASTIG.AuditPolicyRule.ChildNodes.Count
            $skipRuleTypeMultiple               = @('AuditPolicyRule', 'AccountPolicyRule')
            $expectedSkipRuleTypeMultipleCount  = $dscXml.DISASTIG.AuditPolicyRule.ChildNodes.Count + $dscXml.DISASTIG.AccountPolicyRule.ChildNodes.Count
        }

        $userSettingsPath = "$PSScriptRoot\Common.integration.ps1"
        . $userSettingsPath
    }
    #endregion Tests
}
finally
{
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
}
