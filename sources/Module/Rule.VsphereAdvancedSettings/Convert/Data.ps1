# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

<#
    Instructions:  Use this file to add/update/delete REGEX esxpressions that are used in Vmware Advanced Settings.
    Enure expressions are listed from MOST Restrive to LEAST Restrictive, similar to exception handling.  Also, ensure only
    UNIQUE Keys are used in each hashtable to orevent errors and conflicts.
#>


$AdvancedSettingNameList += [ordered]@{
    Vsphere1 = @{
        Select = 'Get-AdvancedSetting -Name ([^\s]+)'
    }
}

$AdvancedSettingDataList += [ordered]@{
    Vsphere1 = @{
        Select = 'You are accessing[^"]+'
    }
    Vsphere2 = @{
        Select = '(?<=is not "|is not set to ")([^"]*)'
    }
    Vsphere3 = @{
        Select = '(?<=verify it is set to |verify it is set to ")(\w+)'
    }
    Vsphere4 = @{
        Select = "(?<=Address is not )(\w+)"
    }
}

$ServiceNameList += [ordered]@{
    Vsphere1 = @{
        Select = '(?<=Label -eq ")([^"]*)'
    }
}
