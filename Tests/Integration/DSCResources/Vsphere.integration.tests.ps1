using module .\helper.psm1

$script:DSCCompositeResourceName = ($MyInvocation.MyCommand.Name -split '\.')[0]
. $PSScriptRoot\.tests.header.ps1

$configFile = Join-Path -Path $PSScriptRoot -ChildPath "$($script:DSCCompositeResourceName).config.ps1"
. $configFile

$stigList = Get-StigVersionTable -CompositeResourceName $script:DSCCompositeResourceName
$resourceInformation = $global:getDscResource | Where-Object -FilterScript {$PSItem.Name -eq $script:DSCCompositeResourceName}
$resourceParameters = $resourceInformation.Properties.Name

$password = ConvertTo-SecureString -AsPlainText -Force -String 'ThisIsAPlaintextPassword'
$credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'Admin', $password

$additionalTestParameterList = @{
    HostIP                     = '10.10.10.10'
    ServerIP                   = '10.10.10.12'
    Credential                 = $credential
    VmGroup                    = @('Vm1','Vm2')
    VirtualStandardSwitchGroup = @('Switch1','Switch2')
    ConfigurationData          = @{
        AllNodes = @(
            @{
                NodeName = 'localhost'
                PSDscAllowDomainUser = $true
                PSDscAllowPlainTextPassword = $true
            }
        )
    }
}

foreach ($stig in $stigList)
{
    $orgSettingsPath = $stig.Path.Replace('.xml', '.org.default.xml')
    $blankSkipRuleId = Get-BlankOrgSettingRuleId -OrgSettingPath $orgSettingsPath
    $powerstigXml = [xml](Get-Content -Path $stig.Path) |
        Remove-DscResourceEqualsNone | Remove-SkipRuleBlankOrgSetting -OrgSettingPath $orgSettingsPath

    $skipRule = Get-Random -InputObject $powerstigXml.VsphereAdvancedSettingsRule.Rule.id
    $skipRuleType = 'VsphereAdvancedSettingsRule'
    $expectedSkipRuleTypeCount = $powerstigXml.VsphereAdvancedSettingsRule.Rule.Count + $blankSkipRuleId.Count

    $skipRuleMultiple = Get-Random -InputObject $powerstigXml.VsphereAdvancedSettingsRule.Rule.id -Count 2
    $skipRuleTypeMultiple = @('VsphereAdvancedSettingsRule','VsphereAcceptanceLevelRule')
    $expectedSkipRuleTypeMultipleCount = ($powerstigXml.VsphereAdvancedSettingsRule.Rule | Measure-Object).Count +
                                         ($powerstigXml.VsphereAcceptanceLevelRule.Rule | Measure-Object).Count +
                                         ($blankSkipRuleId | Measure-Object).Count

    $getRandomExceptionRuleParams = @{
        RuleType       = 'VsphereAdvancedSettingsRule'
        PowerStigXml   = $powerstigXml
        ParameterValue = "'ExceptionKey' = 'ExceptionValue'"
    }

    $exception = Get-RandomExceptionRule @getRandomExceptionRuleParams -Count 1
    $exceptionMultiple = Get-RandomExceptionRule @getRandomExceptionRuleParams -Count 1
    $backCompatException = Get-RandomExceptionRule @getRandomExceptionRuleParams -Count 1 -BackwardCompatibility
    $backCompatExceptionMultiple = Get-RandomExceptionRule @getRandomExceptionRuleParams -Count 1 -BackwardCompatibility

    . "$PSScriptRoot\Common.integration.ps1"
}
