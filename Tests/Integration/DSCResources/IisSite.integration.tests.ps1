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
        WebsiteName = @('WarioSite', 'DKSite')
        WebAppPool = @('MushroomBeach', 'ToadHarbor')
    }

    foreach ($stig in $stigList)
    {
        [xml] $powerstigXml = Get-Content -Path $stig.Path

        $skipRule = Get-Random -InputObject $powerstigXml.DISASTIG.WebConfigurationPropertyRule.Rule.id
        $skipRuleType = "IisLoggingRule"
        $expectedSkipRuleTypeCount = $powerstigXml.DISASTIG.IisLoggingRule.ChildNodes.Count

        $skipRuleMultiple = Get-Random -InputObject $powerstigXml.DISASTIG.MimeTypeRule.Rule.id -Count 2
        $skipRuleTypeMultiple = @('WebAppPoolRule','IisLoggingRule')
        $expectedSkipRuleTypeMultipleCount = $powerstigXml.DISASTIG.WebAppPoolRule.ChildNodes.Count + $powerstigXml.DISASTIG.IisLoggingRule.ChildNodes.Count

        $exception = Get-Random -InputObject ($powerstigXml.DISASTIG.WebConfigurationPropertyRule.Rule |
            Where-Object {[string]::IsNullOrEmpty($PSItem.DuplicateOf)}).id
        $exceptionMultiple = Get-Random -InputObject $powerstigXml.DISASTIG.WebAppPoolRule.Rule.id -Count 2

        . "$PSScriptRoot\Common.integration.ps1"
    }
}
finally
{
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
}
