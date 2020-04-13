# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
#region Method Functions

<#
    .SYNOPSIS
        Assigns.

    .PARAMETER CheckContent
        An array of the raw string data taken from the STIG setting.
#>
function Get-VsphereForgedTransmitsInherited
{
    [CmdletBinding()]
    [OutputType([object])]
    param
    (
        [Parameter(Mandatory = $true)]
        [psobject]
        $RawString
    )

    if ($RawString -match 'Get-VirtualPortGroup')
    {
        $VsphereForgedTransmitsInherited = ($RawString | Select-String -Pattern '(?<=ForgedTransmitsInherited\s)(.\w+)').Matches.Value
    }
    
    if($null -ne $VsphereForgedTransmitsInherited)
    {
        Write-Verbose -Message $("[$($MyInvocation.MyCommand.Name)] Found ForgedTransmitsInherited value: {0}" -f $VsphereForgedTransmitsInherited)
        return $VsphereForgedTransmitsInherited
    }
    else
    {
        return $null
    }
}

function Get-VsphereMacChangesInherited
{
    [CmdletBinding()]
    [OutputType([object])]
    param
    (
        [Parameter(Mandatory = $true)]
        [psobject]
        $RawString
    )

    if ($RawString -match 'Get-VirtualPortGroup')
    {
        $VsphereMacChangesInherited = ($RawString | Select-String -Pattern '(?<=MacChangesInherited\s)(.\w+)').Matches.Value
    }
    
    if($null -ne $VsphereMacChangesInherited)
    {
        Write-Verbose -Message $("[$($MyInvocation.MyCommand.Name)] Found MacChangesInherited value: {0}" -f $VsphereMacChangesInherited)
        return $VsphereMacChangesInherited
    }
    else
    {
        return $null
    }
}

function Get-VsphereAllowPromiscuousInherited
{
    [CmdletBinding()]
    [OutputType([object])]
    param
    (
        [Parameter(Mandatory = $true)]
        [psobject]
        $RawString
    )

    if ($RawString -match 'Get-VirtualPortGroup')
    {
        $VsphereAllowPromiscuousInherited = ($RawString | Select-String -Pattern '(?<=AllowPromiscuousInherited\s)(.\w+)').Matches.Value
    }
    
    if($null -ne $VsphereAllowPromiscuousInherited)
    {
        Write-Verbose -Message $("[$($MyInvocation.MyCommand.Name)] Found AllowPromiscuousInherited value: {0}" -f $VsphereAllowPromiscuousInherited)
        return $VsphereAllowPromiscuousInherited
    }
    else
    {
        return $null
    }
}
