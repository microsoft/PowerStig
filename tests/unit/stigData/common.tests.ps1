#########################################   Begin Header   #########################################
Import-Module "$PSScriptRoot\..\..\helper.psm1" -Force
$StigDataPath = Get-ChildItem -Path "$SrcRootDir\StigData"
$SchemaFile = "$SrcRootDir\StigData\Schema\PowerStig.xsd"
#########################################    End Header    #########################################

Describe 'Common Tests - XML Validation' {

    foreach ($StigDataFolder in $StigDataPath)
    {
        $StigDataName = $StigDataFolder.name

        Context $StigDataName {
            $StigDataXml = Get-ChildItem -Path $StigDataFolder.FullName -Exclude *.org.xml, *org.default.xml
            foreach ($StigDataXmlFile in $StigDataXml)
            {
                It "$($StigDataXmlFile.name) should be a valid xml file" {
                    {Test-Xml -XmlFile $StigDataXmlFile.FullName -SchemaFile $SchemaFile} | Should Not Throw
                }
            }
        }
    }
}
