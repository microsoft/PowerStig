
#region HEADER
$script:moduleRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot) )
Import-Module (Join-Path -Path $moduleRoot -ChildPath 'Tests\helper.psm1') -Force

$StigFileList = Get-ChildItem -Path "$($script:moduleRoot)\StigData" -Exclude "Schema"
$SchemaFile = "$($script:moduleRoot)\StigData\Schema\PowerStig.xsd"
#endregion

Describe 'Common Tests - XML Validation' {

    foreach ($StigDataFolder in $StigFileList)
    {
        $StigDataName = $StigDataFolder.name

        Context $StigDataName {

            $StigDataXml = Get-ChildItem -Path $StigDataFolder.FullName -Exclude *.org.xml, *org.default.xml
            foreach ($StigDataXmlFile in $StigDataXml)
            {
                It "Should be a valid xml file" {
                    {Test-Xml -XmlFile $StigDataXmlFile.FullName -SchemaFile $SchemaFile} | Should Not Throw
                }
            }
        }
    }
}

Describe 'Common Tests - STIG Data Requirements' {
    Context 'Converted STIGs' {
        $stigDataFolder = "$moduleRoot\StigData"
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
