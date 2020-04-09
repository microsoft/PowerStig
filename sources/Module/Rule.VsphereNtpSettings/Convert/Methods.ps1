# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
#region Method Functions

<#
    .SYNOPSIS
        Takes the Name property from a VsphereNtpSettingsRule.

    .PARAMETER CheckContent
        An array of the raw string data taken from the STIG setting.
#>
function Get-VsphereNtpSettings
{
    [CmdletBinding()]
    [OutputType([object])]
    param
    (
        [Parameter(Mandatory = $true)]
        [psobject]
        $CheckContent
    )

    if ($Fixtext -match 'Get-VMHostNTPServer')
    {
        $NTPServer = $null
    }

    if ($null -ne $NTPServer)
    {
        Write-Verbose -Message $("[$($MyInvocation.MyCommand.Name)] NTPServer List Found: {0}" -f $snmpAgent)
        return $snmpAgent
    }
    else
    {
        return $null
    }
}

function Get-VsphereNtpSettingsOrganizationValueTestString
{
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $Id
    )

    If ($this.id -match "V-94039")
    {
        return '{0} is set to a string array of authoritative DoD time sources'
    }
}