# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
#region Method Functions
<#
    .SYNOPSIS
        Retrieves the SqlProtocolTcpIP  port from the check-content element in the xccdf

    .PARAMETER CheckContent
        Specifies the check-content element in the xccdf
#>
function Get-TcpPort
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
        {$PSItem -Match "SQL Server must only use approved network communication libraries, ports, and protocols."}
        {
            $tcpPort = '1433'
        }
    }

    return $tcpPort
}
