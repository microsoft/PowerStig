#region HEADER
$script:moduleRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)))
if ((-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'PowerStig.Tests'))) -or `
     (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'PowerStig.Tests\TestHelper.psm1'))))
{
    & git @('clone','https://github.com/Microsoft/PowerStig.Tests',(Join-Path -Path $script:moduleRoot -ChildPath 'PowerStig.Tests'))
}
Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'PowerStig.Tests' -ChildPath 'TestHelper.psm1')) -Force
$stigDataFolder = Join-Path -Path $script:moduleRoot -ChildPath "StigData"
$stigFileList = Get-ChildItem -Path "$stigDataFolder\Processed"
$schemaFile = "$stigDataFolder\Schema\PowerStig.xsd"
#region HEADER

Describe 'Common Tests - XML Validation' {

    foreach ($stigFile in $stigFileList)
    {
        $StigDataName = $stigFile.name

        Context $StigDataName {

            $StigDataXml = Get-ChildItem -Path $stigFile.FullName -Exclude *.org.xml, *org.default.xml
            foreach ($StigDataXmlFile in $StigDataXml)
            {
                It "Should be a valid xml file" {
                    {Test-Xml -XmlFile $StigDataXmlFile.FullName -SchemaFile $schemaFile} | Should Not Throw
                }
            }
        }
    }
}

Describe 'Common Tests - STIG Data Requirements' {
    Context 'Converted STIGs' {
        $stigDataFolder = "$stigDataFolder\Processed"
        $convertedStigs = Get-ChildItem -Path $stigDataFolder -File | Where-Object {$_.Name -notmatch "\.org\.default\.xml?"}
        $orgSettings = Get-ChildItem -Path $stigDataFolder -File | Where-Object {$_.Name -match "\.org\.default\.xml?"}
        $orgSettings = $orgSettings.BaseName.ToLower()
        $convertedStigs = $convertedStigs.BaseName.ToLower()

        foreach ($stig in $convertedStigs)
        {
            It "$stig should have paired org settings file" {
                $testResult = $true

                if ($orgSettings.Contains(($stig + ".org.default")))
                {
                    continue
                }
                else
                {
                    $testResult = $false

                    Write-Warning -Message "$stig does not have an Org Setting xml. Run 'ConvertTo-DscStigXml' for $stig with the 'CreateOrgSettingsFile' Switch "
                }
                $testResult | Should Be $true
            }
        }
    }
}
