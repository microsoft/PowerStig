# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
#region Functions
<#
 .SYNOPSIS
    Converts the STIGObject to a DnsServerSettingRule
#>
function ConvertTo-DnsServerSettingRule
{
    [CmdletBinding()]
    [OutputType([DnsServerSettingRule])]
    param
    (
        [Parameter(Mandatory = $true)]
        [xml.xmlelement]
        $StigRule
    )

    Write-Verbose "[$($MyInvocation.MyCommand.Name)]"

    $dnsServerSettingRule = [DnsServerSettingRule]::New( $stigRule )

    $dnsServerSettingRule.SetDnsServerPropertyName()

    $dnsServerSettingRule.SetDnsServerPropertyValue()

    $dnsServerSettingRule.SetStigRuleResource()

    if ( $dnsServerSettingRule.IsDuplicateRule( $global:stigSettings ) )
    {
        $dnsServerSettingRule.SetDuplicateTitle()
    }

    if ( $dnsServerSettingRule.IsExistingRule( $global:stigSettings ) )
    {
        $newId = Get-AvailableId -Id $dnsServerSettingRule.Id
        $dnsServerSettingRule.set_id( $newId )
    }

    return $dnsServerSettingRule
}
#endregion
