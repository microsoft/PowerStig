# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

#region Header
using module .\StigClass.psm1
using module ..\common\enum.psm1
. $PSScriptRoot\..\common\data.ps1
#endregion
#region Class Definition
Class DnsServerSettingRule : STIG
{
    [string] $PropertyName
    [string] $PropertyValue

    # Constructors
    DnsServerSettingRule ( [xml.xmlelement] $StigRule )
    {
        $this.InvokeClass( $StigRule )
    }

    # Methods

    [void] SetDnsServerPropertyName ( )
    {
        $thisDnsServerSettingPropertyName = Get-DnsServerSettingProperty -CheckContent $this.SplitCheckContent

        if ( -not $this.SetStatus( $thisDnsServerSettingPropertyName ) )
        {
            $this.set_PropertyName($thisDnsServerSettingPropertyName)
        }
    }

    [void] SetDnsServerPropertyValue ( )
    {
        $thisDnsServerSettingPropertyValue = Get-DnsServerSettingPropertyValue -CheckContent $this.SplitCheckContent

        if ( -not $this.SetStatus( $thisDnsServerSettingPropertyValue ) )
        {
            $this.set_PropertyValue($thisDnsServerSettingPropertyValue)
        }
    }
}
#endregion
#region Method Functions
<#
    .SYNOPSIS
        Retreives the DNS server property setting
#>
function Get-DnsServerSettingProperty
{
    [CmdletBinding()]
    [OutputType( [string] )]
    Param
    (
        [parameter( Mandatory = $true)]
        [string[]]
        $CheckContent
    )

    # There is only have one scenario to handle but we will use a switch to easily add additional scenarios
    switch ( $CheckContent )
    {
        { $CheckContent -match $Script:RegularExpression.textBetweenTheTab }
        {
            $patternMatch = $CheckContent | Select-String -Pattern $Script:RegularExpression.textBetweenTheTab
            $dnsServerPropertyName = ($patternMatch.Matches.groups[-1].Value -replace $Script:RegularExpression.nonLetters).Trim()
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
    [OutputType( [string] )]
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
        { $CheckContent -match $Script:RegularExpression.allEvents}
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
