# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
#region Functions
<#
    .SYNOPSIS
        Processes the raw STIG string that has been identifed as a WMI test.
#>
function ConvertTo-WmiRule
{
    [CmdletBinding()]
    [OutputType([WmiRule])]
    param
    (
        [Parameter(Mandatory = $true)]
        [xml.xmlelement]
        $StigRule
    )

    Write-Verbose "[$($MyInvocation.MyCommand.Name)]"

    return [wmiRule]::New( $StigRule )
}
#endregion
