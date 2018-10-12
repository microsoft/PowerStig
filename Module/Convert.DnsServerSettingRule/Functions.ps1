# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
#region Functions
<#
 .SYNOPSIS
    Converts the STIGObject to a DnsServerSettingRule
#>
function ConvertTo-DnsServerSettingRule
{
    [CmdletBinding()]
    [OutputType([DnsServerSettingRule])]
    param
    (
        [Parameter(Mandatory = $true)]
        [xml.xmlelement]
        $StigRule
    )

    Write-Verbose "[$($MyInvocation.MyCommand.Name)]"

    return [DnsServerSettingRule]::New( $StigRule )
}
#endregion
