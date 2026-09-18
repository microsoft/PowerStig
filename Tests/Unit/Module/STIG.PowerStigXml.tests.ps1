#region Header
. $PSScriptRoot\.tests.header.ps1
#endregion

$xccdfs = (Get-ChildItem -Path $script:moduleRoot\StigData\Archive -Include *xccdf.xml -Recurse | Where-Object -Property Name -Match "Server_2019_MS|IIS_10-0_Server")[1, 3]
foreach ($xccdf in $xccdfs)
{
    Describe "ConvertTo-PowerStigXml $($xccdf.name)" {

        It 'Should return an 2 XML' {
            ConvertTo-PowerStigXml -Path $xccdf.FullName -Destination $TestDrive -CreateOrgSettingsFile -RuleIdFilter $randomId
            $converted = Get-ChildItem -Path $testdrive
            $converted.FullName.EndsWith(".xml").Count | Should -Be 2
        }
    }
}

Describe 'IIS Server V3R7 deterministic conversion' {
    BeforeAll {
        $xccdfPath = Join-Path -Path $script:moduleRoot -ChildPath 'StigData\Archive\Web Server\U_MS_IIS_10-0_Server_STIG_V3R7_Manual-xccdf.xml'
        ConvertTo-PowerStigXml -Path $xccdfPath -Destination $TestDrive
        [xml] $convertedIis = Get-Content -Path (Join-Path -Path $TestDrive -ChildPath 'IISServer-10.0-3.7.xml') -Raw
    }

    $expectedRules = @(
        @{Id = 'V-218794'; Type = 'WebConfigurationPropertyRule'; DscResource = 'Script' },
        @{Id = 'V-218818'; Type = 'WindowsFeatureRule'; DscResource = 'WindowsFeature' },
        @{Id = 'V-218826'; Type = 'WebConfigurationPropertyRule'; DscResource = 'xWebConfigKeyValue' }
    )

    foreach ($expectedRule in $expectedRules)
    {
        It "Should convert $($expectedRule.Id) to $($expectedRule.Type)" {
            $rule = $convertedIis.DISASTIG.ChildNodes.Rule | Where-Object -Property id -EQ $expectedRule.Id
            $rule.ParentNode.Name | Should -Be $expectedRule.Type
            $rule.dscresource | Should -Be $expectedRule.DscResource
            $rule.conversionstatus | Should -Be 'pass'
        }
    }
}

Describe 'ConvertFrom-StigXccdf fallback conversion' {
    It 'Should preserve an unresolved conversion exception as a manual rule' {
        $checkContent = 'Verify the value under HKEY_LOCAL_MACHINE.'
        [xml] $stigRule = Get-TestStigRule -CheckContent $checkContent -XccdfTitle Windows
        $testFile = Join-Path -Path $TestDrive -ChildPath 'UnresolvedFallback.xml'
        $stigRule.Save($testFile)
        $fallback = {
            [pscustomobject] @{
                CorrectedCheckContent = 'HKEY_LOCAL_MACHINE'
                CorrectedFixText      = 'HKEY_LOCAL_MACHINE'
            }
        }

        $rule = ConvertFrom-StigXccdf -Path $testFile -FallbackConverter $fallback

        $rule.GetType().Name | Should Be 'ManualRule'
        $rule.ConversionStatus | Should Be 'pass'
    }

    It 'Should preserve a rejected AI normalization as a manual rule' {
        [xml] $stigRule = Get-TestStigRule -CheckContent 'HKEY_LOCAL_MACHINE\Software\Example' -XccdfTitle Windows
        $testFile = Join-Path -Path $TestDrive -ChildPath 'RejectedNormalization.xml'
        $stigRule.Save($testFile)
        $fallback = {
            [pscustomobject] @{
                CorrectedCheckContent = 'HKEY_LOCAL_MACHINE\Software\Example'
                CorrectedFixText      = 'HKEY_LOCAL_MACHINE\Software\Example'
            }
        }

        $rule = ConvertFrom-StigXccdf -Path $testFile -FallbackConverter $fallback

        $rule.GetType().Name | Should Be 'ManualRule'
        $rule.ConversionStatus | Should Be 'pass'
    }
}

Describe 'PowerStig schema conversion output' {
    It 'Should allow mixed rule types, standalone SQL rules, and unresolved fields' {
        $schemaPath = Join-Path -Path $script:moduleRoot -ChildPath 'StigData\Schema\PowerStig.xsd'
        $testFile = Join-Path -Path $TestDrive -ChildPath 'MixedRuleTypes.xml'
        @'
<DISASTIG classification="UNCLASSIFIED" created="1/1/2026" customname="" description="Test" filename="test.xml" fullversion="1.0" notice="Test" releaseinfo="Test" source="Test" stigid="Test" title="Test" version="1">
    <AuditPolicyRule dscresourcemodule="AuditPolicyDsc">
        <Rule conversionstatus="pass" dscresource="AuditPolicySubcategory" id="V-1" severity="medium" title="Test">
            <Description>Test</Description><DuplicateOf/><IsNullOrEmpty>False</IsNullOrEmpty><OrganizationValueRequired>False</OrganizationValueRequired><OrganizationValueTestString/><RawString>Test</RawString>
        </Rule>
    </AuditPolicyRule>
    <DnsServerRootHintRule dscresourcemodule="xDnsServer">
        <Rule conversionstatus="pass" dscresource="Script" id="V-6.a" severity="medium" title="Test">
            <Description>Test</Description><DuplicateOf/><HostName>$null</HostName><IpAddress>$null</IpAddress><IsNullOrEmpty>False</IsNullOrEmpty><OrganizationValueRequired>False</OrganizationValueRequired><OrganizationValueTestString/><RawString>Test</RawString>
        </Rule>
        <Rule conversionstatus="pass" dscresource="None" id="V-6.b" severity="medium" title="Test">
            <Description>Test</Description><DuplicateOf/><HostName>$null</HostName><IpAddress>$null</IpAddress><IsNullOrEmpty>False</IsNullOrEmpty><OrganizationValueRequired>False</OrganizationValueRequired><OrganizationValueTestString/><RawString>Test</RawString>
        </Rule>
    </DnsServerRootHintRule>
    <DnsServerSettingRule dscresourcemodule="xDnsServer">
        <Rule conversionstatus="fail" dscresource="" id="V-2" severity="medium" title="Test">
            <Description>Test</Description><DuplicateOf/><IsNullOrEmpty>False</IsNullOrEmpty><OrganizationValueRequired>False</OrganizationValueRequired><OrganizationValueTestString/><PropertyName/><PropertyValue/><RawString>Test</RawString>
        </Rule>
    </DnsServerSettingRule>
    <PermissionRule dscresourcemodule="AccessControlDsc">
        <Rule conversionstatus="fail" dscresource="" id="V-3" severity="medium" title="Test">
            <AccessControlEntry><Entry><Type>Fail</Type><Principal>Everyone</Principal><ForcePrincipal>False</ForcePrincipal><Inheritance/><Rights/></Entry></AccessControlEntry><Description>Test</Description><DuplicateOf/><IsNullOrEmpty>False</IsNullOrEmpty><OrganizationValueRequired>False</OrganizationValueRequired><OrganizationValueTestString/><RawString>Test</RawString>
        </Rule>
        <Rule conversionstatus="fail" dscresource="None" id="V-4" severity="medium" title="Test">
            <AccessControlEntry/><Description>Test</Description><DuplicateOf/><IsNullOrEmpty>False</IsNullOrEmpty><OrganizationValueRequired>False</OrganizationValueRequired><OrganizationValueTestString/><RawString>Test</RawString>
        </Rule>
    </PermissionRule>
    <SqlLoginRule dscresourcemodule="SqlServerDsc">
        <Rule conversionstatus="pass" dscresource="SqlLogin" id="V-5" severity="medium" title="Test">
            <Description>Test</Description><DuplicateOf/><Ensure/><IsNullOrEmpty>False</IsNullOrEmpty><LegacyId/><LoginMustChangePassword>False</LoginMustChangePassword><LoginPasswordExpirationEnabled>True</LoginPasswordExpirationEnabled><LoginPasswordPolicyEnforced>True</LoginPasswordPolicyEnforced><LoginType>SqlLogin</LoginType><Name/><OrganizationValueRequired>False</OrganizationValueRequired><OrganizationValueTestString/><RawString>Test</RawString>
        </Rule>
    </SqlLoginRule>
    <SslSettingsRule dscresourcemodule="xWebAdministration">
        <Rule conversionstatus="pass" dscresource="xSslSettings" id="V-7" severity="medium" title="Test">
            <Description>Test</Description><DuplicateOf/><IsNullOrEmpty>False</IsNullOrEmpty><OrganizationValueRequired>False</OrganizationValueRequired><OrganizationValueTestString/><RawString>Test</RawString>
        </Rule>
    </SslSettingsRule>
</DISASTIG>
'@ | Set-Content -Path $testFile -Encoding UTF8
        $issues = [System.Collections.Generic.List[string]]::new()
        $settings = [System.Xml.XmlReaderSettings]::new()
        $settings.ValidationType = [System.Xml.ValidationType]::Schema
        $null = $settings.Schemas.Add($null, $schemaPath)
        $settings.add_ValidationEventHandler({
                param($sender, $eventArgs)
                $issues.Add($eventArgs.Message)
            })

        $reader = [System.Xml.XmlReader]::Create($testFile, $settings)
        try
        {
            while ($reader.Read()) {}
        }
        finally
        {
            $reader.Dispose()
        }

        if ($issues.Count -gt 0)
        {
            throw ($issues -join [Environment]::NewLine)
        }

        $issues.Count | Should Be 0
    }
}

Describe 'Registry conversion expression loading' {
    It 'Should select Chrome expressions independently of the extracted directory name' {
        [xml] $benchmark = '<Benchmark id="Google_Chrome_Current_Windows" />'
        $xccdfPath = Join-Path -Path $TestDrive -ChildPath 'U_Google_Chrome_V2R11_Manual_STIG\Chrome-xccdf.xml'

        Get-RegistryRuleExpressions -Path $xccdfPath -StigBenchmarkXml $benchmark.Benchmark

        $global:SingleLineRegistryValueName.Contains('Chrome1') | Should Be $true
    }
}

<# Describe 'Compare-PowerStigXml' {

    $dotNetSTIGS = (Get-ChildItem -Path $script:moduleRoot\StigData\Processed -Recurse | Where-Object -Property Name -Match "(DotNetFramework-4-.*\d.xml)").FullName
    It 'Should return a PSObject' {
        $compare = Compare-PowerStigXml -OldStigPath $dotNetSTIGS[0] -NewStigPath $dotNetSTIGS[1]
        $compare.GetType().ToString()  | Should -Be "System.Object[]"
    }
}
#>
Describe 'Get-BaseRulePropertyName' {

    It 'Should return 12 base rule types' {
        $baseRulePropertyName = Get-BaseRulePropertyName
        $baseRulePropertyName.Count  | Should -Be 12
    }
}

Describe 'Get-DynamicParameterRuleTypeName' {

    Get-BaseRulePropertyName
    It 'Should return a runtime defined parameter dictionary' {
        $dynamicParameterRuleTypeName = Get-DynamicParameterRuleTypeName
        $dynamicParameterRuleTypeName.GetType().ToString() | Should -Be "System.Management.Automation.RuntimeDefinedParameterDictionary"
    }
}
