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

        if ($stig.TechnologyRole -eq 'Domain')
        {
            continue
        }
        else
        {
            $exception          = Get-Random -InputObject $powerstigXml.DISASTIG.RegistryRule.Rule.id
            $exceptionMultiple  = Get-Random -InputObject $powerstigXml.DISASTIG.RegistryRule.Rule.id -Count 2
            $skipRule           = Get-Random -InputObject $powerstigXml.DISASTIG.RegistryRule.Rule.id
            $skipRuleMultiple   = Get-Random -InputObject $powerstigXml.DISASTIG.RegistryRule.Rule.id -Count 2
            $skipRuleType               = "AuditPolicyRule"
            $expectedSkipRuleTypeCount  = $powerstigXml.DISASTIG.AuditPolicyRule.ChildNodes.Count
            $skipRuleTypeMultiple               = @('AuditPolicyRule', 'AccountPolicyRule')
            $expectedSkipRuleTypeMultipleCount  = $powerstigXml.DISASTIG.AuditPolicyRule.ChildNodes.Count + $powerstigXml.DISASTIG.AccountPolicyRule.ChildNodes.Count
        }

        $commonIntegrationTests = "$PSScriptRoot\Common.integration.ps1"
        . $commonIntegrationTests
    }
}
finally
{
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
}
