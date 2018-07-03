#region Header
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\..\Public\Class\Common.Enum.psm1
using module .\..\..\Public\Data\Convert.Data.psm1
# Class module
using module .\..\..\Public\Class\Convert.ManualRule.psm1
#endregion
#region Main Functions
<#
    .SYNOPSIS
        Accepts the raw stig string data and converts it to a manual check object.
#>
function ConvertTo-ManualRule
{
    [CmdletBinding()]
    [OutputType([ManualRule])]
    Param
    (
        [parameter(Mandatory = $true)]
        [xml.xmlelement]
        $StigRule
    )

    Write-Verbose "[$($MyInvocation.MyCommand.Name)]"

    $manualRule = [ManualRule]::New( $StigRule )

    $manualRule.SetStigRuleResource()

    return $manualRule
}
#endregion
