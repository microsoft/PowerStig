# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
#region Functions
<#
    .SYNOPSIS
        Accepts the raw stig string data and converts it to a manual check object.
#>
function ConvertTo-ManualRule
{
    [CmdletBinding()]
    [OutputType([ManualRule])]
    param
    (
        [Parameter(Mandatory = $true)]
        [xml.xmlelement]
        $StigRule
    )

    Write-Verbose "[$($MyInvocation.MyCommand.Name)]"

    $manualRule = [ManualRule]::New( $StigRule )

    $manualRule.SetStigRuleResource()

    return $manualRule
}
#endregion
