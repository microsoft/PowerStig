$convertModulePath = "C:\Program Files\WindowsPowerShell\Modules\PowerSTIG\4.28.0\PowerStig.Convert.psm1"
$destination = "C:\stig\feb2025\Converted"
$XccdfPath = "c:\stig\feb2025\STIGs\xccdf\U_MS_IIS_10-0_Server_STIG_V3R6_Manual-xccdf.xml"
Import-Module PowerStig
import-module -FullyQualifiedName $convertModulePath

ConvertTo-PowerStigXml -Destination $destination -Path $XccdfPath -CreateOrgSettingsFile