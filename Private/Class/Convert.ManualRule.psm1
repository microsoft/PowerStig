# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

#region Header
using module ..\..\public\Class\ManualRuleClass.psm1
using module ..\..\public\common\enum.psm1
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
