# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

<#
    Instructions:  Use this file to add/update/delete REGEX esxpressions that are used in Vmware services.
    Ensure expressions are listed from MOST Restrive to LEAST Restrictive, similar to exception handling.  Also, ensure only
    UNIQUE Keys are used in each hashtable to orevent errors and conflicts.
#>


$ServiceNameList += [ordered]@{
    Vsphere1 = @{
        Select = '(?<=Label -eq ")([^"]*)'
    }
}

$ServicePolicyList += [ordered]@{
    Vsphere1 = @{
        Select = '(?<=verify it is )(\w+)'
    }
}
