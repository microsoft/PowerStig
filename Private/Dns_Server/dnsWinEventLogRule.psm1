# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

#region Header
using module ..\..\public\Class\DnsServerSettingRuleClass.psm1
using module ..\..\public\Class\WinEventLogRuleClass.psm1
using module ..\..\public\common\enum.psm1
using module ..\common\helperFunctions.psm1
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
