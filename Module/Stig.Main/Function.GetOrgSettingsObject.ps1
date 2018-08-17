# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

<#
.SYNOPSIS
    Creates an OrganizationSetting object

.PARAMETER OrgSettings
    OrgSettings can be either a string path to an OrganizationalFile XML or a hash table of org settings
    to override from the default organization file.

.RETURN
    OrganizationalSetting

.EXAMPLE
    Get-OrgSettingsObject -OrgSettings @{"v-1000"="15"}
#>
Function Get-OrgSettingsObject
{
    [CmdletBinding()]
    [OutputType([OrganizationalSetting])]
    param
    (
        [Parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]
        [PSObject]
        $OrgSettings
    )

    switch ($OrgSettings.GetType())
    {
        "string"
        {
            if (Test-Path -Path $OrgSettings)
            {
                [xml] $orgSettingsXml = Get-Content -Path $orgSettings
                $orgSettingsObject = [OrganizationalSetting]::ConvertFrom($orgSettingsXml)
            }
            else
            {
                Throw "Organizational file not found"
            }
        }
        "xml"
        {
            $orgSettingsObject = [OrganizationalSetting]::ConvertFrom($OrgSettings)
        }
        "hashtable"
        {
            $orgSettingsObject = [OrganizationalSetting]::ConvertFrom($OrgSettings)
        }
    }

    return $orgSettingsObject
}
