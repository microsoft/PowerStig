# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

<#
    .SYNOPSIS
        Returns an array of all available STIGs with the associated Technology, TechnologyVersion, TechnologyRole, and StigVersion.
        This function is a wrapper of the StigData class, and the return of this function call will provide you with the values needed
        to create a default StigData object.

    .EXAMPLE
        Get-StigList
#>
Function Get-StigList
{
    [CmdletBinding()]
    [OutputType([PSObject[]])]
    param ()

    return [StigData]::GetAvailableStigs()
}
