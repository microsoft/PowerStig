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

$xccdfs =  Get-ChildItem -path $PSScriptRoot\UnitTestHelperFiles -Include *xccdf.xml -Recurse

foreach($xccdf in $xccdfs)
{
    [xml]$test = get-content $xccdf
    $randomId = $test.Benchmark.Group.Id | Get-Random
    Describe 'ConvertFrom-StigXccdf' {

        It 'Should return an object array' {
            $convertedXccdf = ConvertFrom-StigXccdf -Path $xccdf.FullName
            $convertedXccdf.gettype().toString()  | Should be "System.Object[]"
        }

        It 'Should return one rule' {
            $convertedXccdfId = ConvertFrom-StigXccdf -Path $xccdf.FullName -RuleIdFilter $randomId
            if($convertedXccdfId.id.Count -ge 2)
            {
                $convertedXccdfId.Id[0].split('.')[0] | Should be $randomId
            }
            else
            {
                $convertedXccdfId.Id | Should be $randomId
            }

        }
    }

    Describe 'ConvertTo-PowerStigXml' {

        It 'Should return an 2 XMLs' {
            ConvertTo-PowerStigXml -Path $xccdf.FullName -Destination $TestDrive -CreateOrgSettingsFile -RuleIdFilter $randomId
            $converted = Get-ChildItem $testdrive
            $converted.FullName.EndsWith(".xml").Count | Should be 2
        }
    }
}

Describe 'Compare-PowerStigXml' {

    $dotNetSTIGS = Get-ChildItem -path $PSScriptRoot\UnitTestHelperFiles -Include DotNetFramework* -Recurse
    It 'Should return a PSObject' {
        $Compare = Compare-PowerStigXml -OldStigPath $dotNetSTIGS[0] -NewStigPath $dotNetSTIGS[1]
        $Compare.gettype().toString()  | Should be "System.Object[]"
    }
}