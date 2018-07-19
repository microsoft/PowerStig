# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
#region Method Functions
<#
    .SYNOPSIS
        Retrieves the DNS server property setting
#>
function Get-DnsServerSettingProperty
{
    [CmdletBinding()]
    [OutputType([string])]
    Param
    (
        [parameter( Mandatory = $true)]
        [string[]]
        $CheckContent
    )

    # There is only one scenario to handle but we will use a switch to easily add additional scenarios
    switch ( $CheckContent )
    {
        { $CheckContent -match $script:regularExpression.textBetweenTheTab }
        {
            $patternMatch = $CheckContent | Select-String -Pattern $script:regularExpression.textBetweenTheTab
            $dnsServerPropertyName = ($patternMatch.Matches.groups[-1].Value -replace $script:regularExpression.nonLetters).Trim()
            $dnsServerPropertyName = $Script:DnsServerSetting[$dnsServerPropertyName]

            break
        }
        Default
        {
        }
    }

    return $dnsServerPropertyName
}

<#
    .SYNOPSIS
        Retrieves the Dns Server Setting Property Value
#>
function Get-DnsServerSettingPropertyValue
{
    [CmdletBinding()]
    [OutputType([string])]
    Param
    (
        [parameter( Mandatory = $true)]
        [string[]]
        $CheckContent
    )

    $MyCommand = $MyInvocation.MyCommand.Name

    Write-Verbose "[$MyCommand]"

    switch ( $CheckContent )
    {
        { $CheckContent -match $script:regularExpression.allEvents}
        {
            # 4 equals all events
            $dnsServerSettingPropertyValue = 4

            break
        }

        default
        {
            $dnsServerSettingPropertyValue = '$True'
        }
    }

    return $dnsServerSettingPropertyValue
}
#endregion
