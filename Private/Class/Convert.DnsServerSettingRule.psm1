# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

#region Header
using module ..\..\public\Class\DnsServerSettingRuleClass.psm1
using module ..\..\public\common\enum.psm1
using module ..\common\helperFunctions.psm1
#endregion header
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
