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
    Param
    (
        [parameter(Mandatory = $true)]
        [xml.xmlelement]
        $StigRule
    )

    Write-Verbose "[$($MyInvocation.MyCommand.Name)]"

    $serviceRule = [ServiceRule]::New( $StigRule )

    $serviceRule.SetServiceName()

    $serviceRule.SetServiceState()

    $serviceRule.SetStartupType()

    $serviceRule.SetStigRuleResource()
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

<#
    .SYNOPSIS
        Looks in the Check-Content element to see if it matches a service check string.

    .PARAMETER CheckContent
        Check-Content element
#>
function Test-MatchServiceRule
{
    [CmdletBinding()]
    [OutputType([bool])]
    Param
    (
        [parameter(Mandatory = $true)]
        [string]
        $CheckContent
    )
    # Find Service settings but exclude the 'Unnecessary Service' rule
    if ( $CheckContent -Match 'services\.msc' -and $CheckContent -NotMatch 'Required Services' -and $CheckContent -NotMatch 'presence of applications' )
    {
        return $true
    }

    return $false
}
#endregion
