#region Header
. $PSScriptRoot\.tests.header.ps1
#endregion

#Get-RegistryRuleExpressions
#ConvertTo-PowerStigXml
#Compare-PowerStigXml
#New-OrganizationalSettingsXmlFile
#get-StigObjectsWithOrgSettings
#Get-OrgSettingPropertyFromStigRule
#Get-HardCodedRuleLogFileEntry()
#Get-BaseRulePropertyName()
#Get-DynamicParameterRuleTypeName()
#Get-RuleChangeLog()

$xccdfPath = "$PSScriptRoot\UnitTestHelperFiles\U_MS_Windows_Server_2019_MS_STIG_V1R5_Manual-xccdf.xml"

Describe 'ConvertFrom-StigXccdf' {

    It 'Should return an object array' {
        $convertedXccdf = ConvertFrom-StigXccdf -Path $xccdfPath
        $convertedXccdf.gettype().toString()  | Should be "System.Object[]"
    }

    It 'Should return one rule' {
        $convertedXccdfId = ConvertFrom-StigXccdf -Path $xccdfPath -RuleIdFilter "V-92965"
        $convertedXccdfId.Id  | Should be "V-92965"
    }
}
