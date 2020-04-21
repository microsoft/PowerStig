# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
#region Method Functions

<#
    .SYNOPSIS
        Takes the Name property from a VsphereKernelActiveDumpPartitionRule.

    .PARAMETER CheckContent
        An array of the raw string data taken from the STIG setting.
#>
function Get-VsphereKernelActiveDumpPartition
{
    [CmdletBinding()]
    [OutputType([object])]
    param
    (
        [Parameter(Mandatory = $true)]
        [psobject]
        $RawString
    )

    if ($RawString -match 'coredump.partition')
    {
        $KernelActiveDumpPartitionEnabled = ($RawString | Select-String -Pattern '(?<=coredump.network.set\()(.\w+)(?=\))').matches.value
    }

    if ($null -ne $KernelActiveDumpPartitionEnabled)
    {
        Write-Verbose -Message $("[$($MyInvocation.MyCommand.Name)] Found Host Kernel Active Dump Partition Enabled: {0}" -f $KernelActiveDumpPartitionEnabled)
        return $KernelActiveDumpPartitionEnabled
    }
    else
    {
        return $null
    }
}
