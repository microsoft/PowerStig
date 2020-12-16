# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

<#
    Instructions:  Use this file to add/update/delete regsitry expressions that are used accross 
    multiple technologies files that are considered commonly used.  Ensure expressions are listed
    from MOST Restrive to LEAST Restrictive, similar to exception handling.  Also, ensure only
    UNIQUE Keys are used in each hashtable to prevent errors and conflicts.
#>

$global:SingleLineRegistryValueName += [ordered]@{
    Chrome1 = @{
        Select = '(?<=3. If the\s|\s")\w+(?=("\s|\s)value name|\skey)'
    }
}

$global:SingleLineRegistryValueData += [ordered]@{
    Chrome1 = @{
        Select = "(?<=entries 1 set to )\w+\:\/\/\*"
    }
    Chrome2 = @{
        Select = '(?<=its value data is not set to\s|\s\")\d+|\*'
    }
}
