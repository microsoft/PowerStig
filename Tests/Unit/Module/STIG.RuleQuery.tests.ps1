#region Header
. $PSScriptRoot\.tests.header.ps1
#endregion

$xmlTestData = @'
<DISASTIG version="1" classification="UNCLASSIFIED" customname="" stigid="TestSTIGData" description="Test STIG Data" filename="U_Test_Data_STIG_V1R1_Manual-xccdf.xml" releaseinfo="Release: 1 Benchmark Date: 14 Nov 2016" title="Test STIG Data Security Technical Implementation Guide" notice="terms-of-use" source="STIG.DOD.MIL" fullversion="1.1" created="9/6/2019">
  <RegistryRule dscresourcemodule="PSDscResources">
    <Rule id="V-1000" severity="medium" conversionstatus="pass" title="SRG-APP-000000" dscresource="Registry">
      <Description>&lt;VulnDiscussion&gt;Test STIG Description&lt;/VulnDiscussion&gt;&lt;</Description>
      <DuplicateOf />
      <Ensure>Present</Ensure>
      <IsNullOrEmpty>False</IsNullOrEmpty>
      <Key>HKEY_LOCAL_MACHINE\Software\Microsoft\TestKeyData</Key>
      <OrganizationValueRequired>False</OrganizationValueRequired>
      <OrganizationValueTestString />
      <RawString>Test Data RawString</RawString>
      <ValueData>TestValueData</ValueData>
      <ValueName>TestValueName</ValueName>
      <ValueType>String</ValueType>
    </Rule>
  </RegistryRule>
</DISASTIG>
'@

$exceptionString = "V-1000 = @{Ensure = 'Present'; Key = 'HKEY_LOCAL_MACHINE\Software\Microsoft\TestKeyData'; ValueData = 'TestValueData'; ValueName = 'TestValueName'; ValueType = 'String'}"


try
{
    Describe 'Rule Query Functions' {

        $testProcessedXml = Join-Path -Path $TestDrive -ChildPath 'TestProcessedXml.xml'
        Set-Content -Path $testProcessedXml -Value $xmlTestData

        Context 'Get-StigRule' {
            It 'Should return a V-1000 Rule PSCustomObject Non-Detailed' {
                $getStigRuleResult = Get-StigRule -VulnId 'V-1000' -ProcessedXmlPath $testProcessedXml
                $getStigRuleResult.RuleType | Should -Be 'RegistryRule'
                $getStigRuleResult.VulnId | Should -Be 'V-1000'
                $getStigRuleResult.Ensure | Should -Be 'Present'
                $getStigRuleResult.Key | Should -Be 'HKEY_LOCAL_MACHINE\Software\Microsoft\TestKeyData'
                $getStigRuleResult.ValueData | Should -Be 'TestValueData'
                $getStigRuleResult.ValueName | Should -Be 'TestValueName'
                $getStigRuleResult.ValueType | Should -Be 'String'
            }

            It 'Should return a V-1000 Rule PSCustomObject Detailed' {
                $getStigRuleResult = Get-StigRule -VulnId 'V-1000' -ProcessedXmlPath $testProcessedXml -Detailed
                $getStigRuleResult.StigId | Should -Be 'TestSTIGData'
                $getStigRuleResult.StigVersion | Should -Be '1.1'
                $getStigRuleResult.Severity | Should -Be 'medium'
                $getStigRuleResult.Title | Should -Be 'SRG-APP-000000'
                $getStigRuleResult.Description | Should -Be 'Test STIG Description'
                $getStigRuleResult.RuleType | Should -Be 'RegistryRule'
                $getStigRuleResult.DscResource | Should -Be 'Registry'
                $getStigRuleResult.DuplicateOf | Should -Be $([string]::Empty)
                $getStigRuleResult.OrganizationValueRequired | Should -Be 'False'
                $getStigRuleResult.OrganizationValueTestString | Should -Be $([string]::Empty)
                $getStigRuleResult.VulnId | Should -Be 'V-1000'
                $getStigRuleResult.Ensure | Should -Be 'Present'
                $getStigRuleResult.Key | Should -Be 'HKEY_LOCAL_MACHINE\Software\Microsoft\TestKeyData'
                $getStigRuleResult.ValueData | Should -Be 'TestValueData'
                $getStigRuleResult.ValueName | Should -Be 'TestValueName'
                $getStigRuleResult.ValueType | Should -Be 'String'
            }
        }

        Context 'Get-StigRuleExceptionString' {
            It 'Should return a valid unformatted exception string' {
                $ruleData = Get-StigRule -VulnId 'V-1000' -ProcessedXmlPath $testProcessedXml
                $getStigRuleExceptionString = Get-StigRuleExceptionString -Rule $ruleData
                $getStigRuleExceptionString | Should -Be $exceptionString
            }

            It 'Should return a valid formatted exception string' {
                $ruleData = Get-StigRule -VulnId 'V-1000' -ProcessedXmlPath $testProcessedXml
                $getStigRuleExceptionStringFormatted = Get-StigRuleExceptionString -Rule $ruleData -Formatted
                $getStigRuleExceptionStringFormatted | Should -BeOfType System.String
            }
        }
    }
}
finally
{
    . $PSScriptRoot\.tests.footer.ps1
}