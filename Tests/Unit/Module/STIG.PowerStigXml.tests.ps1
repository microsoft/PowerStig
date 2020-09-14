#region Header
. $PSScriptRoot\.tests.header.ps1
#endregion

$xccdfs = (Get-ChildItem -Path $script:moduleRoot\StigData\Archive -Include *xccdf.xml -Recurse | Where-Object -Property Name -Match "Server_2019_MS|IIS_10-0_Server")[1,3]
foreach ($xccdf in $xccdfs)
{
    Describe "ConvertTo-PowerStigXml $($xccdf.name)" {

        It 'Should return an 2 XML' {
            ConvertTo-PowerStigXml -Path $xccdf.FullName -Destination $TestDrive -CreateOrgSettingsFile -RuleIdFilter $randomId
            $converted = Get-ChildItem $testdrive
            $converted.FullName.EndsWith(".xml").Count | Should be 2
        }
    }
}

Describe 'Compare-PowerStigXml' {

    $dotNetSTIGS = (Get-ChildItem -Path $script:moduleRoot\StigData\Processed -Recurse | Where-Object -Property Name -Match "(DotNetFramework-4-.*\d.xml)").FullName
    It 'Should return a PSObject' {
        $Compare = Compare-PowerStigXml -OldStigPath $dotNetSTIGS[0] -NewStigPath $dotNetSTIGS[1]
        $Compare.gettype().toString()  | Should be "System.Object[]"
    }
}

Describe 'Get-BaseRulePropertyName' {

    It 'Should return 11 base rule types' {
        $BaseRulePropertyName = Get-BaseRulePropertyName
        $BaseRulePropertyName.count  | Should be 11
    }
}

Describe 'Get-DynamicParameterRuleTypeName' {

    Get-BaseRulePropertyName
    It 'Should return a runtime defined parameter dictionary' {
        $DynamicParameterRuleTypeName = Get-DynamicParameterRuleTypeName
        $DynamicParameterRuleTypeName.GetType().toString() | Should be "System.Management.Automation.RuntimeDefinedParameterDictionary"
    }
}
