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
        $orgSettingsPath = $stig.Path.Replace('.xml', '.org.default.xml')
        $blankSkipRuleId = Get-BlankOrgSettingRuleId -OrgSettingPath $orgSettingsPath
        $powerstigXml = [xml](Get-Content -Path $stig.Path) |
            Remove-DscResourceEqualsNone | Remove-SkipRuleBlankOrgSetting -OrgSettingPath $orgSettingsPath

        $skipRule = Get-Random -InputObject $powerstigXml.RegistryRule.Rule.id
        $skipRuleType = $null
        $expectedSkipRuleTypeCount = 0 + $blankSkipRuleId.Count

        $skipRuleMultiple = Get-Random -InputObject $powerstigXml.RegistryRule.Rule.id -Count 2
        $skipRuleTypeMultiple = $null
        $expectedSkipRuleTypeMultipleCount = 0 + $blankSkipRuleId.Count

        $getRandomExceptionRuleParams = @{
            RuleType       = 'RegistryRule'
            PowerStigXml   = $powerstigXml
            ParameterValue = 1234567
        }
        $exception = Get-RandomExceptionRule @getRandomExceptionRuleParams -Count 1
        $exceptionMultiple = Get-RandomExceptionRule @getRandomExceptionRuleParams -Count 2

        . "$PSScriptRoot\Common.integration.ps1"
    }
}
finally
{
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
}
