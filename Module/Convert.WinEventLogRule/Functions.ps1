# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
#region Functions
function ConvertTo-WinEventLogRule
{
    [CmdletBinding()]
    [OutputType([WinEventLogRule])]
    param
    (
        [Parameter(Mandatory = $true)]
        [xml.xmlelement]
        $StigRule
    )

    Write-Verbose "[$($MyInvocation.MyCommand.Name)]"

    $dnsWinEventLogRule = [WinEventLogRule]::New( $stigRule )
    $dnsWinEventLogRule.SetWinEventLogName()

    # Get the DNS Server setting PropertyValue
    $dnsWinEventLogRule.SetWinEventLogIsEnabled()

    # If a duplicate is found ' Duplicate' is appended to the title
    if ( $dnsWinEventLogRule.IsDuplicateRule( $global:stigSettings ) )
    {
        $dnsWinEventLogRule.SetDuplicateTitle()
    }

    if ( $dnsWinEventLogRule.IsExistingRule( $global:stigSettings ) )
    {
        $newId = Get-AvailableId -Id $stigRule.id
        $dnsWinEventLogRule.set_id( $newId )
    }

    $dnsWinEventLogRule.SetStigRuleResource()

    return $dnsWinEventLogRule
}
#endregion
