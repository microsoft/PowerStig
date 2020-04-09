# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
#region Method Functions

<#
    .SYNOPSIS
        Takes the Name property from a VsphereSnmpAgentRule.

    .PARAMETER CheckContent
        An array of the raw string data taken from the STIG setting.
#>
function Get-VsphereSnmpAgent
{
    [CmdletBinding()]
    [OutputType([object])]
    param
    (
        [Parameter(Mandatory = $true)]
        [psobject]
        $RawString
    )

    if ($Fixtext -match 'Get-VMHostSnmp')
    {
        $snmpAgent = ($RawString | Select-String -Pattern '(?<=Set-VMHostSnmp -Enabled\s)(.\w+)').matches.value
    }

    if ($null -ne $nnmpAgent)
    {
        Write-Verbose -Message $("[$($MyInvocation.MyCommand.Name)] Found Host SNMP Enabled: {0}" -f $snmpAgent)
        return $snmpAgent
    }
    else
    {
        return $null
    }
}
