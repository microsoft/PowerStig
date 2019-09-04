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
        configPath = 'C:\Windows\Sun\Java\Deployment\deployment.config'
        propertiesPath = 'C:\Windows\Java\Deployment\deployment.properties'
    }

    foreach ($stig in $stigList)
    {
<<<<<<< HEAD
<<<<<<< HEAD
        $powerstigXml = [xml](Get-Content -Path $stig.Path) | Remove-DscResourceEqualsNone
=======
=======
>>>>>>> origin/4.0.0
        $orgSettingsPath = $stig.Path.Replace('.xml', '.org.default.xml')
        $blankSkipRuleId = Get-BlankOrgSettingRuleId -OrgSettingPath $orgSettingsPath
        $powerstigXml = [xml](Get-Content -Path $stig.Path) |
            Remove-DscResourceEqualsNone | Remove-SkipRuleBlankOrgSetting -OrgSettingPath $orgSettingsPath
<<<<<<< HEAD
>>>>>>> origin/4.0.0
=======
>>>>>>> origin/4.0.0

        $skipRule = Get-Random -InputObject $powerstigXml.FileContentRule.Rule.id
        $skipRuleType = $null
        $expectedSkipRuleTypeCount = 0 + $blankSkipRuleId.Count

        $skipRuleMultiple = Get-Random -InputObject $powerstigXml.FileContentRule.Rule.id -Count 2
        $skipRuleTypeMultiple = $null
<<<<<<< HEAD
<<<<<<< HEAD
        $expectedSkipRuleTypeMultipleCount = 0

        $exception = Get-Random -InputObject $powerstigXml.FileContentRule.Rule.id
        $exceptionMultiple = Get-Random -InputObject $powerstigXml.FileContentRule.Rule.id -Count 2
=======
=======
>>>>>>> origin/4.0.0
        $expectedSkipRuleTypeMultipleCount = 0 + $blankSkipRuleId.Count

        $getRandomExceptionRuleParams = @{
            RuleType       = 'FileContentRule'
            PowerStigXml   = $powerstigXml
            ParameterValue = 1234567
        }
        $exception = Get-RandomExceptionRule @getRandomExceptionRuleParams -Count 1
        $exceptionMultiple = Get-RandomExceptionRule @getRandomExceptionRuleParams -Count 2
<<<<<<< HEAD
>>>>>>> origin/4.0.0
=======
>>>>>>> origin/4.0.0

        . "$PSScriptRoot\Common.integration.ps1"
    }
}
finally
{
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
}
