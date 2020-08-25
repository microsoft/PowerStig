using module .\helper.psm1

$script:DSCCompositeResourceName = ($MyInvocation.MyCommand.Name -split '\.')[0]
. $PSScriptRoot\.tests.header.ps1

$configFile = Join-Path -Path $PSScriptRoot -ChildPath "$($script:DSCCompositeResourceName).config.ps1"
. $configFile

$stigList = Get-StigVersionTable -CompositeResourceName $script:DSCCompositeResourceName

$password = ConvertTo-SecureString -AsPlainText -Force -String 'ThisIsAPlaintextPassword'
$SetupAccount = New-Object -TypeName pscredential -ArgumentList 'Admin', $password
$WebAppUrl = "test.com"

$additionalTestParameterList    = @{
    SetupAccount        = $SetupAccount
    WebAppUrl           = $WebAppUrl
    ConfigurationData   = @{
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

    $skipRule = Get-Random -InputObject $powerstigXml.SharePointSPWebAppGeneralSettingsRule.Rule.id
    $skipRuleType = "SharePointSPWebAppGeneralSettingsRule"
    $expectedSkipRuleTypeCount = 2 + $blankSkipRuleId.Count

    $skipRuleMultiple = Get-Random -InputObject $powerstigXml.SharePointSPWebAppGeneralSettingsRule.Rule.id -Count 2
    $skipRuleTypeMultiple = "SharePointSPWebAppGeneralSettingsRule"
    $expectedSkipRuleTypeMultipleCount = ($blankSkipRuleId | Measure-Object).Count

    $exception = @{
        'V-59919' = @{
            PropertyValue = 14
        }
    }
    $exceptionMultiple = @{
        'V-59919' = @{
            PropertyValue = 14
        }
        'V-59957' = @{
            PropertyValue = 'Permissive'
        }
    }

    . "$PSScriptRoot\Common.integration.ps1"
}
