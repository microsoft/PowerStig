#region Header
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\..\Public\Class\Common.Enum.psm1
using module .\..\..\Public\Data\Convert.Data.psm1
# Class module
using module .\..\public\Class\Convert.DnsServerSettingRule.psm1
#endregion 
#region Main Functions
<#
 .SYNOPSIS
    Converts the STIGObject to a DnsServerSettingRule
#>
function ConvertTo-DnsServerSettingRule
{
    [CmdletBinding()]
    [OutputType( [DnsServerSettingRule] )]
    Param
    (
        [parameter(Mandatory = $true)]
        [xml.xmlelement]
        $StigRule
    )

    Write-Verbose "[$($MyInvocation.MyCommand.Name)]"

    $dnsServerSettingRule = [DnsServerSettingRule]::New( $StigRule )

    $dnsServerSettingRule.SetDnsServerPropertyName()

    $dnsServerSettingRule.SetDnsServerPropertyValue()

    $dnsServerSettingRule.SetStigRuleResource()

    if ( $dnsServerSettingRule.IsDuplicateRule( $Global:STIGSettings ) )
    {
        $dnsServerSettingRule.SetDuplicateTitle()
    }

    if ( $dnsServerSettingRule.IsExistingRule( $Global:STIGSettings ) )
    {
        $newId = Get-AvailableId -Id $dnsServerSettingRule.Id
        $dnsServerSettingRule.set_id( $newId )
    }

    return $dnsServerSettingRule
}
#endregion Main Functions
