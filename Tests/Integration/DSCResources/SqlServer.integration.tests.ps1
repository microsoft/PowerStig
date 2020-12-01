using module .\helper.psm1

$script:DSCCompositeResourceName = ($MyInvocation.MyCommand.Name -split '\.')[0]
. $PSScriptRoot\.tests.header.ps1

$configFile = Join-Path -Path $PSScriptRoot -ChildPath "$($script:DSCCompositeResourceName).config.ps1"
. $configFile

$stigList = Get-StigVersionTable -CompositeResourceName $script:DSCCompositeResourceName
$resourceInformation = $global:getDscResource | Where-Object -FilterScript {$PSItem.Name -eq $script:DSCCompositeResourceName}
$resourceParameters = $resourceInformation.Properties.Name

foreach ($stig in $stigList)
{
    $orgSettingsPath = $stig.Path.Replace('.xml', '.org.default.xml')
    $blankSkipRuleId = Get-BlankOrgSettingRuleId -OrgSettingPath $orgSettingsPath
    $powerstigXml = [xml](Get-Content -Path $stig.Path) |
        Remove-DscResourceEqualsNone | Remove-SkipRuleBlankOrgSetting -OrgSettingPath $orgSettingsPath

    $skipRule = Get-Random -InputObject $powerstigXml.SqlScriptQueryRule.Rule.id
    $skipRuleType = "SqlScriptQueryRule"
    $expectedSkipRuleTypeCount = ($powerstigXml.SqlScriptQueryRule.Rule | Measure-Object).Count + $blankSkipRuleId.Count

    $skipRuleMultiple = Get-Random -InputObject $powerstigXml.SqlScriptQueryRule.Rule.id -Count 2
    $skipRuleTypeMultiple = $null
    $expectedSkipRuleTypeMultipleCount = 0 + $blankSkipRuleId.Count

    $singleSkipRuleSeverity = 'CAT_I'
    $multipleSkipRuleSeverity = 'CAT_I', 'CAT_II'
    $expectedSingleSkipRuleSeverity = Get-CategoryRule -PowerStigXml $powerstigXml -RuleCategory $singleSkipRuleSeverity
    $expectedSingleSkipRuleSeverityCount = ($expectedSingleSkipRuleSeverity | Measure-Object).Count + $blankSkipRuleId.Count
    $expectedMultipleSkipRuleSeverity = Get-CategoryRule -PowerStigXml $powerstigXml -RuleCategory $multipleSkipRuleSeverity
    $expectedMultipleSkipRuleSeverityCount = ($expectedMultipleSkipRuleSeverity | Measure-Object).Count + $blankSkipRuleId.Count

    $getRandomExceptionRuleParams = @{
        RuleType       = 'SqlScriptQueryRule'
        PowerStigXml   = $powerstigXml
        ParameterValue = 1234567
    }
    $exception = Get-RandomExceptionRule @getRandomExceptionRuleParams -Count 1
    $exceptionMultiple = $null
    $backCompatException = Get-RandomExceptionRule @getRandomExceptionRuleParams -Count 1 -BackwardCompatibility
    $backCompatExceptionMultiple = $null

    . "$PSScriptRoot\Common.integration.ps1"
}
