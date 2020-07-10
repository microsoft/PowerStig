<#
    Data file used to create the .nuspec file which is used to create the package.
    There is a "static" dependency for Vmware.vSphereDsc which is not included with
    the RequiredModules section in the PowerStig manifest file due to a cyclic
    dependency bug in PowerShell 5.1 which will not be fixed.
#>
data nuspecContents {
@'
<?xml version="1.0" encoding="utf-8"?>
<package xmlns="http://schemas.microsoft.com/packaging/2011/08/nuspec.xsd">
  <metadata>
    <id>PowerStig</id>
    <version>{0}</version>
    <authors>{1}</authors>
    <owners>{2}</owners>
    <licenseUrl>{3}</licenseUrl>
    <projectUrl>{4}</projectUrl>
    <requireLicenseAcceptance>false</requireLicenseAcceptance>
    <description>{5}</description>
    <releaseNotes>{6}</releaseNotes>
    <copyright>{7} {8}</copyright>
    <tags>{9}</tags>
    <dependencies>
{10}
      <dependency id="Vmware.vSphereDsc" version="[2.1.0.58]" />
    </dependencies>
  </metadata>
  <files>
    <file src="PowerStig\{11}\**" target="" />
  </files>
</package>
'@
}