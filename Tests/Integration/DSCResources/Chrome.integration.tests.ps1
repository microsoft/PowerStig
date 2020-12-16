using module .\helper.psm1

$script:DSCCompositeResourceName = ($MyInvocation.MyCommand.Name -split '\.')[0]
. $PSScriptRoot\.tests.header.ps1

$configFile = Join-Path -Path $PSScriptRoot -ChildPath "$($script:DSCCompositeResourceName).config.ps1"
. $configFile

$script:DSCCompositeResourceNameUpdate = "Google-{0}" -f ($MyInvocation.MyCommand.Name -split '\.')[0]
$stigList = Get-StigVersionTable -CompositeResourceName $script:DSCCompositeResourceNameUpdate
$resourceInformation = $global:getDscResource | Where-Object -FilterScript {$PSItem.Name -eq $script:DSCCompositeResourceName}
$resourceParameters = $resourceInformation.Properties.Name

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

    $singleSkipRuleSeverity = 'CAT_I'
    $multipleSkipRuleSeverity = 'CAT_I', 'CAT_II'
    $expectedSingleSkipRuleSeverity = Get-CategoryRule -PowerStigXml $powerstigXml -RuleCategory $singleSkipRuleSeverity
    $expectedSingleSkipRuleSeverityCount = ($expectedSingleSkipRuleSeverity | Measure-Object).Count + $blankSkipRuleId.Count
    $expectedMultipleSkipRuleSeverity = Get-CategoryRule -PowerStigXml $powerstigXml -RuleCategory $multipleSkipRuleSeverity
    $expectedMultipleSkipRuleSeverityCount = ($expectedMultipleSkipRuleSeverity | Measure-Object).Count + $blankSkipRuleId.Count

    $getRandomExceptionRuleParams = @{
        RuleType       = 'RegistryRule'
        PowerStigXml   = $powerstigXml
        ParameterValue = 1234567
    }
    $exception = Get-RandomExceptionRule @getRandomExceptionRuleParams -Count 1
    $exceptionMultiple = Get-RandomExceptionRule @getRandomExceptionRuleParams -Count 2
    $backCompatException = Get-RandomExceptionRule @getRandomExceptionRuleParams -Count 1 -BackwardCompatibility
    $backCompatExceptionMultiple = Get-RandomExceptionRule @getRandomExceptionRuleParams -Count 2 -BackwardCompatibility

    . "$PSScriptRoot\Common.integration.ps1"
}
