#region Header
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\..\Public\Class\Common.Enum.psm1
using module .\..\..\Public\Data\Convert.Data.psm1
# Class module
using module .\..\..\Public\Class\Convert.DnsServerSettingRule.psm1
using module .\..\..\Public\Class\Convert.WinEventLogRule.psm1
#endregion
#region Main Functions
<#
 .SYNOPSIS
    Converts the STIGObject to a DnsWinEventLogRule
#>
function ConvertTo-WinEventLogRule
{
    [CmdletBinding()]
    [OutputType( [WinEventLogRule] )]
    param
    (
        [parameter(Mandatory = $true)]
        [xml.xmlelement]
        $StigRule
    )

    Write-Verbose "[$($MyInvocation.MyCommand.Name)]"

    $dnsWinEventLogRule = [WinEventLogRule]::New( $StigRule )
    $dnsWinEventLogRule.SetWinEventLogName()

    # Get the DNS Server setting PropertyValue
    $dnsWinEventLogRule.SetWinEventLogIsEnabled()

    # If a duplicate is found ' Duplicate' is appended to the title
    if ( $dnsWinEventLogRule.IsDuplicateRule( $Global:STIGSettings ) )
    {
        $dnsWinEventLogRule.SetDuplicateTitle()
    }

    if ( $dnsWinEventLogRule.IsExistingRule( $Global:STIGSettings ) )
    {
        $newId = Get-AvailableId -Id $StigRule.id
        $dnsWinEventLogRule.set_id( $newId )
    }

    $dnsWinEventLogRule.SetStigRuleResource()

    return $dnsWinEventLogRule
}
#endregion
