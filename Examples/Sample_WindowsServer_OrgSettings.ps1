<#
    .SYNOPSIS
        Apply the Windows Server STIG to a node, but override the default
        organizational settings with a local file

    .DESCRIPTION
        Provide an organizational range XML file to merge into the main STIG
        settings. In this example, the Windows Server 2012R2 member server STIG
        is processed by the composite resource. Instead of merging in the default
        values for any settings that have a valid range, the organization has
        provided a list of values to merge into the valid ranges.
#>
configuration Example
{
    param
    (
        [parameter()]
        [string]
        $NodeName = 'localhost'
    )

    Import-DscResource -ModuleName PowerStig

    Node $NodeName
    {
        WindowsServer BaseLine
        {
            OsVersion   = '2012R2'
            OsRole      = 'MS'
            StigVersion = '2.12'
            DomainName  = 'sample.test'
            ForestName  = 'sample.test'
            OrgSettings = "$PSScriptRoot\orgsettings.xml"
        }
    }
}

# Create a sample Organizational Settings file for the example to use.
@"
<?xml version="1.0"?>
<!-- The organizational settings file is used to define the local organizations preferred setting within an allowed range of the STIG. Each setting in this file is linked by STIG ID and the valid range is in an associated comment. -->
<OrganizationalSettings version="2.12">
    <!-- Ensure 'V-1090' -le '4'-->
    <OrganizationalSetting value="3" id="V-1090"/>
    <!-- Ensure ''V-1097'' -le '3' -and ''V-1097'' -ne '0'-->
    <OrganizationalSetting value="2" id="V-1097"/>
    <!-- Ensure ''V-1098'' -ge '15'-->
    <OrganizationalSetting value="16" id="V-1098"/>
</OrganizationalSettings>
"@ | Out-File -FilePath "$PSScriptRoot\orgsettings.xml"

Example

