using module .\helper.psm1

$script:DSCCompositeResourceName = ($MyInvocation.MyCommand.Name -split '\.')[0]
. $PSScriptRoot\.tests.header.ps1

$configFile = Join-Path -Path $PSScriptRoot -ChildPath "$($script:DSCCompositeResourceName).config.ps1"
. $configFile

$stigList = Get-StigVersionTable -CompositeResourceName $script:DSCCompositeResourceName

$password = ConvertTo-SecureString -AsPlainText -Force -String 'ThisIsAPlaintextPassword'
$SetupAccount = New-Object -TypeName pscredential -ArgumentList 'Admin', $password
$WebAppUrl = 'test.com'
$BrowserFileHandling = 'Strict'

$additionalTestParameterList    = @{
    SetupAccount        = $SetupAccount
    WebAppUrl           = $WebAppUrl
    BrowserFileHandling = $BrowserFileHandling
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
    $expectedSkipRuleTypeCount = $powerstigXml.SharePointSPWebAppGeneralSettingsRule.Rule.Count + $blankSkipRuleId.Count

    $skipRuleMultiple = Get-Random -InputObject $powerstigXml.SharePointSPWebAppGeneralSettingsRule.Rule.id -Count 4 #grab 4 random spwebappgeneralsettings rules and assign them to skiprulemultiple, then pass to common integration tests
    $skipRuleTypeMultiple = 'SharePointSPWebAppGeneralSettingsRule'
    $expectedSkipRuleTypeMultipleCount = 0 + $blankSkipRuleId.Count

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
