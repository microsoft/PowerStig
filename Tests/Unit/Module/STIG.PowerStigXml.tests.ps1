#region Header
. $PSScriptRoot\.tests.header.ps1
#endregion

$xccdfs = (Get-ChildItem -Path $script:moduleRoot\StigData\Archive -Include *xccdf.xml -Recurse | Where-Object -Property Name -Match "Server_2019_MS|IIS_10-0_Server")[1,3]
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

Describe 'Compare-PowerStigXml' {

    $dotNetSTIGS = (Get-ChildItem -Path $script:moduleRoot\StigData\Processed -Recurse | Where-Object -Property Name -Match "(DotNetFramework-4-.*\d.xml)").FullName
    It 'Should return a PSObject' {
        $compare = Compare-PowerStigXml -OldStigPath $dotNetSTIGS[0] -NewStigPath $dotNetSTIGS[1]
        $compare.GetType().ToString()  | Should -Be "System.Object[]"
    }
}

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
