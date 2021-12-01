# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
#region Method Functions
<#
    .SYNOPSIS
        Retrieves the SqlProtocol type from the check-content element in the xccdf

    .PARAMETER CheckContent
        Specifies the check-content element in the xccdf
#>
function Get-ProtocolName
{
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $CheckContent
    )

    switch ($checkcontent) 
    {
        {$PSItem -Match "If Named Pipes is enabled"}
        {
            $protocolName = 'NamedPipes'
        }
    }

    return $protocolName
}

<#
    .SYNOPSIS
        Sets the SqlProtocol enabled status

    .PARAMETER CheckContent
        Specifies the check-content element in the xccdf
#>
function Set-Enabled
{
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $CheckContent
    )

    switch ($checkContent)
    {
        {$PSItem -Match "If Named Pipes is enabled"}
        {
            $enabledStatus = $false
        }
    }

    return $enabledStatus
}
