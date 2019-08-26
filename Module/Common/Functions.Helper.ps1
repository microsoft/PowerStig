# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
# Header

function ConvertTo-OrgSettingHashtable
{
    [CmdletBinding()]
    [OutputType([hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [xml]
        $XmlOrgSetting
    )

    $result = @{}
    foreach ($ruleId in $XmlOrgSetting.OrganizationalSettings.OrganizationalSetting)
    {
        $ruleIdValues = @{}
        $ruleIdProperty = $ruleId.Attributes.Name | Where-Object -FilterScript {$PSItem -ne 'id'}
        foreach ($property in $ruleIdProperty)
        {
            $ruleIdValues.Add($property, ($ruleId.GetAttribute($property)))
        }
        $result.Add($ruleId.id, $ruleIdValues)
    }

    return $result
}

function Merge-OrgSettingValue
{
    [CmdletBinding()]
    [OutputType([hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [hashtable]
        $DefaultOrgSetting,

        [Parameter(Mandatory = $true)]
        [hashtable]
        $UserSpecifiedOrgSetting
    )

    foreach ($ruleId in $UserSpecifiedOrgSetting.Keys)
    {
        $DefaultOrgSetting[$ruleId] = $UserSpecifiedOrgSetting[$ruleId]
    }

    return $DefaultOrgSetting
}
