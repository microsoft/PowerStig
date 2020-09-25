using module .\helper.psm1

$script:DSCCompositeResourceName = ($MyInvocation.MyCommand.Name -split '\.')[0]
. $PSScriptRoot\.tests.header.ps1

$configFile = Join-Path -Path $PSScriptRoot -ChildPath "$($script:DSCCompositeResourceName).config.ps1"
. $configFile

$stigList = Get-StigVersionTable -CompositeResourceName $script:DSCCompositeResourceName
$resourceInformation = $global:getDscResource | Where-Object -FilterScript {$PSItem.Name -eq $script:DSCCompositeResourceName}
$resourceParameters = $resourceInformation.Properties.Name

$password = ConvertTo-SecureString -AsPlainText -Force -String 'ThisIsAPlaintextPassword'
$SetupAccount = New-Object -TypeName pscredential -ArgumentList 'Admin', $password

$WebAppUrl = 'https://sharePoint.contoso.com'

$SPAlternateUrlItem = @{Url = "https://Other.contoso.com"; WebAppName = "Other web App"; Zone = "Default"; Internal = "$False"}

$SPLogLevelItems = @(
    @{"Area" = "SharePoint Server";"Name" = "Database";"TraceLevel" = "Verbose";"EventLevel" = "Error"},
    @{"Area" = "Business Connectivity Services";"Name" = "Business Data";"TraceLevel" = "Verbose";"EventLevel" = "Information"},
    @{"Area" = "Search";"Name" = "Content Processing";"TraceLevel" = "Verbose";"EventLevel" = "Error"}
)

$additionalTestParameterList    = @{
    SetupAccount = $SetupAccount
    ConfigurationData           = @{
        AllNodes = @(
            @{
                NodeName = 'localhost'
                PSDscAllowDomainUser = $true
                PSDscAllowPlainTextPassword = $true
            }
        )
    }
    WebAppUrl = $WebAppUrl
    SPLogLevelItems = $SPLogLevelItems
    SPAlternateUrlItem = $SPAlternateUrlItem
}

foreach ($stig in $stigList)
{
    $orgSettingsPath = $stig.Path.Replace('.xml', '.org.default.xml')
    $blankSkipRuleId = Get-BlankOrgSettingRuleId -OrgSettingPath $orgSettingsPath
    $powerstigXml = [xml](Get-Content -Path $stig.Path) | Remove-DscResourceEqualsNone | Remove-SkipRuleBlankOrgSetting -OrgSettingPath $orgSettingsPath

    $skipRule = Get-Random -InputObject $powerstigXml.SPWebAppGeneralSettingsRule.Rule.id
    $skipRuleType = "SPWebAppGeneralSettingsRule"
    $expectedSkipRuleTypeCount = $powerstigXml.SPWebAppGeneralSettingsRule.Rule.Count + $blankSkipRuleId.Count

    $skipRuleMultiple = Get-Random -InputObject $powerstigXml.SPWebAppGeneralSettingsRule.Rule.id -Count 4
    $skipRuleTypeMultiple = 'SPWebAppGeneralSettingsRule'
    $expectedSkipRuleTypeMultipleCount = $powerstigXml.SPWebAppGeneralSettingsRule.Rule.Count + $blankSkipRuleId.Count

    $singleSkipRuleSeverity = 'CAT_I'
    $multipleSkipRuleSeverity = 'CAT_I', 'CAT_II'
    $expectedSingleSkipRuleSeverity = Get-CategoryRule -PowerStigXml $powerstigXml -RuleCategory $singleSkipRuleSeverity
    $expectedSingleSkipRuleSeverityCount = ($expectedSingleSkipRuleSeverity | Measure-Object).Count + $blankSkipRuleId.Count
    $expectedMultipleSkipRuleSeverity = Get-CategoryRule -PowerStigXml $powerstigXml -RuleCategory $multipleSkipRuleSeverity
    $expectedMultipleSkipRuleSeverityCount = ($expectedMultipleSkipRuleSeverity | Measure-Object).Count + $blankSkipRuleId.Count

    $getRandomExceptionRuleParams = @{
        RuleType        = 'SPWebAppGeneralSettingsRule'
        PowerStigXml    = $powerstigXml
        ParameterValue  = "Strict"
    }

    <#
    $exception = Get-RandomExceptionRule @getRandomExceptionRuleParams -Count 1
    $exceptionMultiple = Get-RandomExceptionRule @getRandomExceptionRuleParams -Count 2
    $backCompatException = Get-RandomExceptionRule @getRandomExceptionRuleParams -Count 1 -BackwardCompatibility
    $backCompatExceptionMultiple = Get-RandomExceptionRule @getRandomExceptionRuleParams -Count 2 -BackwardCompatibility
#>
    . "$PSScriptRoot\Common.integration.ps1"
}
