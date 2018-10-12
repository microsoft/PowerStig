# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
#region Functions
<#
    .SYNOPSIS
        Accepts the raw stig string data and converts it to a IisLoggingRule object.

    .PARAMETER StigRule
        The xml Stig rule from the XCCDF.
#>
function ConvertTo-IisLoggingRule
{
    [CmdletBinding()]
    [OutputType([IisLoggingRule])]
    param
    (
        [Parameter(Mandatory = $true)]
        [xml.xmlelement]
        $StigRule
    )

    Write-Verbose "[$($MyInvocation.MyCommand.Name)]"

    return [IisLoggingRule]::New( $StigRule )
}
#endregion
