# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

<#
    .SYNOPSIS
        Retreives the service name from the check-content element in the xccdf

    .PARAMETER FixText
        Specifies the FixText element in the xccdf
#>
function Get-nxServiceName
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
        $null = $FixText -match $regularExpression.nxServiceName
        $nxServiceName = $Matches['serviceName']
        return $nxServiceName
    }
    catch
    {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] nxServiceName : Not Found"
        return $null
    }
}

<#
    .SYNOPSIS
        Retreives the service state from the check-content element in the xccdf

    .PARAMETER FixText
        Specifies the check-content element in the xccdf
#>
function Get-nxServiceState
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
        $null = $FixText -match $regularExpression.nxServiceState
        switch ($Matches['serviceState'])
        {
            {$PSItem -match 'restart|start'}
            {
                return 'Running'
            }
            {$PSItem -match 'stop'}
            {
                return 'Stopped'
            }
            default
            {
                return $null
            }
        }
    }
    catch
    {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] nxServiceState : Not Found"
        return $null
    }
}

<#
    .SYNOPSIS
        Retreives the service enablement from the check-content element in the xccdf

    .PARAMETER FixText
        Specifies the check-content element in the xccdf
#>
function Get-nxServiceEnabled
{
    [CmdletBinding()]
    [OutputType([bool])]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $FixText
    )

    Write-Verbose "[$($MyInvocation.MyCommand.Name)]"
    try
    {
        $null = $FixText -match $regularExpression.nxServiceEnabled
        switch ($Matches['serviceEnabled'])
        {
            {$PSItem -match 'enable'}
            {
                return $true
            }
            {$PSItem -match 'disable'}
            {
                return $false
            }
            default
            {
                return
            }
        }
    }
    catch
    {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] nxServiceEnabled : Not Found"
        return
    }
}