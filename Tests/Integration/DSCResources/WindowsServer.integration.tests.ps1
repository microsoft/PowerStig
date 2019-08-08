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

    $additionalTestParameterList = @{
        ForestName = 'integration.test'
        DomainName = 'integration.test'
    }

    foreach ($stig in $stigList)
    {
        $powerstigXml = [xml](Get-Content -Path $stig.Path) | Remove-DscResourceEqualsNone

        if ($stig.TechnologyRole -eq 'Domain')
        {
            continue
        }
        else
        {
            $exception          = Get-Random -InputObject $powerstigXml.RegistryRule.Rule.id
            $exceptionMultiple  = Get-Random -InputObject $powerstigXml.RegistryRule.Rule.id -Count 2
            $skipRule           = Get-Random -InputObject $powerstigXml.RegistryRule.Rule.id
            $skipRuleMultiple   = Get-Random -InputObject $powerstigXml.RegistryRule.Rule.id -Count 2
            $skipRuleType               = "AuditPolicyRule"
            $expectedSkipRuleTypeCount  = $powerstigXml.AuditPolicyRule.Rule.Count
            $skipRuleTypeMultiple               = @('AuditPolicyRule', 'AccountPolicyRule')
            $expectedSkipRuleTypeMultipleCount  = $powerstigXml.AuditPolicyRule.Rule.Count + $powerstigXml.AccountPolicyRule.Rule.Count
        }

        . "$PSScriptRoot\Common.integration.ps1"
    }
}
finally
{
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
}
