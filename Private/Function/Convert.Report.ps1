# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

#region Main Functions
<#
    .SYNOPSIS
        Simply returns an alphabetical list of STIG types. This helps with additional
        sorting and searching.
#>
function Get-RuleTypeList
{
    param
    (
        [parameter(Mandatory = $true)]
        [PSCustomObject]
        $StigSettings
    )

    $global:stigSettings |
        ForEach-Object {$PSItem.GetType().ToString()} |
            Select-Object -Unique |
                Sort-Object
}
#endregion
