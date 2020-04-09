# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
#region Method Functions

<#
    .SYNOPSIS
        Takes the Name property from a VsphereServiceRule.

    .PARAMETER CheckContent
        An array of the raw string data taken from the STIG setting.
#>
function Get-VsphereServiceName
{
    [CmdletBinding()]
    [OutputType([object])]
    param
    (
        [Parameter(Mandatory = $true)]
        [psobject]
        $CheckContent
    )

    if ($CheckContent -match 'Get-VMHostService')
    {
        $matchName = ($CheckContent | Select-String -Pattern $ServiceNameList.Values.Values).matches.groups[1].value

        foreach($item in $ServiceNameList.Values.Values)
        {
            if ($null -eq $matchValue)
            {
                $serviceName = ($Checkcontent | Select-String -Pattern $item).Matches.Value | Get-Unique
            }
        }
    }

    if ($null -ne $serviceName)
    {
        Write-Verbose -Message $("[$($MyInvocation.MyCommand.Name)] Found Service name: {0}" -f $serviceName)
        return $serviceName
    }
    else
    {
        return $null
    }
}

<#
    .SYNOPSIS
        Gets the startup policy and running status from a vsphere service rule.

    .PARAMETER CheckContent
        An array of the raw string data taken from the STIG setting.
#>

function Get-VsphereServicePolicy
{
    [CmdletBinding()]
    [OutputType([object])]
    param
    (
        [Parameter(Mandatory = $true)]
        [psobject]
        $CheckContent
    )

    if ($CheckContent -match 'Get-VMHostService')
    {
        $ServicePolicy = ($CheckContent | Select-String -Pattern $ServicePolicyList.Values.Values).matches.value
        if($ServicePolicy -eq "stopped")
        {
            $servicePolicy = "off"
            $serviceRunning = $false
        }
        else {
            $ServicePolicy = "on"
            $serviceRunning = $true
        }
    }

    if ($null -ne $ServicePolicy)
    {
        Write-Verbose -Message $("[$($MyInvocation.MyCommand.Name)] Found Service Policy: {0}" -f $ServicePolicy)
        return $servicePolicy,$serviceRunning
    }
    else
    {
        return $null
    }
}
