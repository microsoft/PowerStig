# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

<#
    .SYNOPSIS
        Retreives the nxPackage name from the check-content element in the xccdf

    .PARAMETER FixText
        Specifies the FixText element in the xccdf
#>
function Get-nxPackageName
{
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $FixText
    )

    Write-Verbose "[$($MyInvocation.MyCommand.Name)]"
    try
    {
        $null = $FixText -match $regularExpression.nxPackage
        $nxPackageName = $Matches['packageName']
        return $nxPackageName
    }
    catch
    {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] nxPackageName : Not Found"
        return $null
    }
}

<#
    .SYNOPSIS
        Retreives the nxPackage InstallState from the check-content element in the xccdf

    .PARAMETER FixText
        Specifies the check-content element in the xccdf
#>
function Get-nxPackageState
{
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $FixText
    )

    try
    {
        $null = $FixText -match $regularExpression.nxPackage
        switch ($Matches['packageState'])
        {
            'install' {return [ensure]::Present}
            'remove'  {return [ensure]::Absent}
            default   {return $null}
        }
    }
    catch
    {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] nxPackageState : Not Found"
        return $null
    }
}
