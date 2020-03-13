# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

<#
    Instructions:  Use this file to add/update/delete regsitry expressions that are used accross 
    multiple technologies files that are considered commonly used.  Enure expressions are listed
    from MOST Restrive to LEAST Restrictive, similar to exception handling.  Also, ensure only
    UNIQUE Keys are used in each hashtable to orevent errors and conflicts.
#>

$global:SingleLineRegistryValueName += [ordered]@{
    McAfee1 = @{
        Match  = 'Wow6432Node\\McAfee'
        Select = '(?<=If the value of\s)(\w+)'
    }
    McAfee2 = @{
        Match  = 'Wow6432Node\\McAfee'
        Select = '(?<=If the value for\s)(\w+)'
    }
    McAfee3 = @{
        Match  = 'Wow6432Node\\McAfee'
        Select = '(?<=If the value\s)(\w+)'
    }
}
