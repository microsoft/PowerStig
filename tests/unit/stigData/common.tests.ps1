
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
