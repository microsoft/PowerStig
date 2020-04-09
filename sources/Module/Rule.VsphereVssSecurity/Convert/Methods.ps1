# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
#region Method Functions

<#
    .SYNOPSIS
        Assigns.

    .PARAMETER CheckContent
        An array of the raw string data taken from the STIG setting.
#>
function Get-VsphereForgedTransmits
{
    [CmdletBinding()]
    [OutputType([object])]
    param
    (
        [Parameter(Mandatory = $true)]
        [psobject]
        $RawString
    )

    if ($RawString -match 'Get-VirtualSwitch')
    {
        $VsphereForgedTransmits = ($RawString | Select-String -Pattern '(?<=ForgedTransmits\s)(.\w+)').Matches.Value
    }
    
    if($null -ne $VsphereForgedTransmits)
    {
        Write-Verbose -Message $("[$($MyInvocation.MyCommand.Name)] Found ForgedTransmits value: {0}" -f $VsphereForgedTransmits)
        return $VsphereForgedTransmits
    }
    else
    {
        return $null
    }
}

function Get-VsphereMacChanges
{
    [CmdletBinding()]
    [OutputType([object])]
    param
    (
        [Parameter(Mandatory = $true)]
        [psobject]
        $RawString
    )

    if ($RawString -match 'Get-VirtualSwitch')
    {
        $VsphereMacChanges = ($RawString | Select-String -Pattern '(?<=MacChanges\s)(.\w+)').Matches.Value
    }
    
    if($null -ne $VsphereMacChanges)
    {
        Write-Verbose -Message $("[$($MyInvocation.MyCommand.Name)] Found MacChanges value: {0}" -f $VsphereMacChanges)
        return $VsphereMacChanges
    }
    else
    {
        return $null
    }
}

function Get-VsphereAllowPromiscuous
{
    [CmdletBinding()]
    [OutputType([object])]
    param
    (
        [Parameter(Mandatory = $true)]
        [psobject]
        $RawString
    )

    if ($RawString -match 'Get-VirtualSwitch')
    {
        $VsphereAllowPromiscuous = ($RawString | Select-String -Pattern '(?<=AllowPromiscuous\s)(.\w+)').Matches.Value
    }
    
    if($null -ne $VsphereAllowPromiscuous)
    {
        Write-Verbose -Message $("[$($MyInvocation.MyCommand.Name)] Found AllowPromiscuous value: {0}" -f $VsphereAllowPromiscuous)
        return $VsphereAllowPromiscuous
    }
    else
    {
        return $null
    }
}
