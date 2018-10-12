# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
#region Functions
<#
    .SYNOPSIS
        Processes the raw STIG string that has been identifed as a Service configuration.
#>
function ConvertTo-ServiceRule
{
    [CmdletBinding()]
    [OutputType([ServiceRule])]
    param
    (
        [Parameter(Mandatory = $true)]
        [xml.xmlelement]
        $StigRule
    )

    Write-Verbose "[$($MyInvocation.MyCommand.Name)]"

    $serviceRule = [ServiceRule]::New( $StigRule )

    $serviceRule.SetServiceName()

    $serviceRule.SetServiceState()

    $serviceRule.SetStartupType()

    $ServiceName = $serviceRule.Servicename

    if ( [ServiceRule]::HasMultipleRules( $ServiceName ) )
    {
        $firstElement = $true
        [int] $byte = 97
        $tempRule = $serviceRule.Clone()
        [string[]] $splitRules = [ServiceRule]::SplitMultipleRules( $ServiceName )
        foreach ( $serviceName in $splitRules )
        {
            if ( $firstElement )
            {
                $serviceRule.ServiceName = $serviceName
                $serviceRule.id = "$($serviceRule.id).$([CHAR][BYTE]$byte)"
                $firstElement = $false
            }
            else
            {
                $newRule = $tempRule.Clone()
                $newRule.ServiceName = $serviceName
                $newRule.id = "$($newRule.id).$([CHAR][BYTE]$byte)"
                [void] $global:stigSettings.Add($newRule)
            }
            $byte++
        }
    }

    return $serviceRule
}

#endregion
