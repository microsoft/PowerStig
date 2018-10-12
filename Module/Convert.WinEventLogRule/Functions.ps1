# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
#region Functions
function ConvertTo-WinEventLogRule
{
    [CmdletBinding()]
    [OutputType([WinEventLogRule])]
    param
    (
        [Parameter(Mandatory = $true)]
        [xml.xmlelement]
        $StigRule
    )

    Write-Verbose "[$($MyInvocation.MyCommand.Name)]"

    return [WinEventLogRule]::New( $StigRule )
}
#endregion
