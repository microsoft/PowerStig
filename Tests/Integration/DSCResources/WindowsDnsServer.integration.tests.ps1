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
<<<<<<< HEAD
<<<<<<< HEAD
        $powerstigXml = [xml](Get-Content -Path $stig.Path) | Remove-DscResourceEqualsNone

        $skipRule = Get-Random -InputObject ($powerstigXml.DnsServerSettingRule.Rule |
            Where-Object { [string]::IsNullOrEmpty($PsItem.DuplicateOf) }).id

        $skipRuleType = "PermissionRule"
        $expectedSkipRuleTypeCount = ($powerstigXml.PermissionRule.Rule |
            Where-Object { [string]::IsNullOrEmpty($PsItem.DuplicateOf) }).Count

        $skipRuleMultiple = Get-Random -InputObject ($powerstigXml.DnsServerSettingRule.Rule |
            Where-Object { [string]::IsNullOrEmpty($PsItem.DuplicateOf) }).id -Count 2
        $skipRuleTypeMultiple = @('PermissionRule','UserRightRule')
        $expectedSkipRuleTypeMultipleCount = ($powerstigXml.PermissionRule.Rule + $powerstigXml.UserRightRule.Rule |
            Where-Object { [string]::IsNullOrEmpty($PsItem.DuplicateOf) }).Count

        $exception = Get-Random -InputObject $powerstigXml.UserRightRule.Rule.id
        $exceptionMultiple = Get-Random -InputObject $powerstigXml.UserRightRule.Rule.id -Count 2
=======
        $orgSettingsPath = $stig.Path.Replace('.xml', '.org.default.xml')
        $blankSkipRuleId = Get-BlankOrgSettingRuleId -OrgSettingPath $orgSettingsPath
        $powerstigXml = [xml](Get-Content -Path $stig.Path) |
            Remove-DscResourceEqualsNone | Remove-SkipRuleBlankOrgSetting -OrgSettingPath $orgSettingsPath

        $skipRule = Get-Random -InputObject ($powerstigXml.DnsServerSettingRule.Rule |
            Where-Object {[string]::IsNullOrEmpty($PsItem.DuplicateOf)}).id

        $skipRuleType = "PermissionRule"
        $expectedSkipRuleTypeCount = ($powerstigXml.PermissionRule.Rule |
            Where-Object {[string]::IsNullOrEmpty($PsItem.DuplicateOf)}).Count + $blankSkipRuleId.Count

        $skipRuleMultiple = Get-Random -InputObject ($powerstigXml.DnsServerSettingRule.Rule |
            Where-Object {[string]::IsNullOrEmpty($PsItem.DuplicateOf)}).id -Count 2
        $skipRuleTypeMultiple = @('PermissionRule','UserRightRule')
        $expectedSkipRuleTypeMultipleCount = ($powerstigXml.PermissionRule.Rule + $powerstigXml.UserRightRule.Rule |
=======
        $orgSettingsPath = $stig.Path.Replace('.xml', '.org.default.xml')
        $blankSkipRuleId = Get-BlankOrgSettingRuleId -OrgSettingPath $orgSettingsPath
        $powerstigXml = [xml](Get-Content -Path $stig.Path) |
            Remove-DscResourceEqualsNone | Remove-SkipRuleBlankOrgSetting -OrgSettingPath $orgSettingsPath

        $skipRule = Get-Random -InputObject ($powerstigXml.DnsServerSettingRule.Rule |
            Where-Object {[string]::IsNullOrEmpty($PsItem.DuplicateOf)}).id

        $skipRuleType = "PermissionRule"
        $expectedSkipRuleTypeCount = ($powerstigXml.PermissionRule.Rule |
            Where-Object {[string]::IsNullOrEmpty($PsItem.DuplicateOf)}).Count + $blankSkipRuleId.Count

        $skipRuleMultiple = Get-Random -InputObject ($powerstigXml.DnsServerSettingRule.Rule |
            Where-Object {[string]::IsNullOrEmpty($PsItem.DuplicateOf)}).id -Count 2
        $skipRuleTypeMultiple = @('PermissionRule','UserRightRule')
        $expectedSkipRuleTypeMultipleCount = ($powerstigXml.PermissionRule.Rule + $powerstigXml.UserRightRule.Rule |
>>>>>>> origin/4.0.0
            Where-Object {[string]::IsNullOrEmpty($PsItem.DuplicateOf)}).Count + $blankSkipRuleId.Count

        $getRandomExceptionRuleParams = @{
            RuleType       = 'UserRightRule'
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
