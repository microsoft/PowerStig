# // Copyright (c) Microsoft Corporation. All rights reserved.// Licensed under the MIT license.

using module .\..\Class\StigData.psm1

<#
.SYNOPSIS
    Returns an array of all available STIGs with the associated Technology, TechnologyVersion, TechnologyRole, and StigVersion.
    This function is a wrapper of the StigData class, and the return of this function call will provide you with the values needed
    to create a default StigData object.

.RETURN
    PSObject[]

.EXAMPLE
    Get-StigList
#>
Function Get-StigList
{
    [cmdletbinding()]
    [outputtype([PSObject[]])]
    Param
    (
    )

    return [StigData]::GetAvailableStigs()
}
