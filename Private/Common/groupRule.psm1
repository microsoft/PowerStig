# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

#region Header
using module ..\..\public\Class\GroupRuleClass.psm1
using module ..\..\public\common\enum.psm1
#endregion
#region Main Functions
<#
    .SYNOPSIS
       Calls the GroupRule class to generate an local group specfic object.
#>
function ConvertTo-GroupRule
{
    [OutputType([GroupRule])]
    Param
    (
        [parameter(Mandatory = $true)]
        [xml.xmlelement]
        $StigRule
    )

    $groupRule = [GroupRule]::New( $StigRule )
    $groupRule.SetGroupName()
    $groupRule.SetMembersToExclude()
    $groupRule.SetStigRuleResource()

    if ($groupRule.conversionstatus -eq 'pass')
    {
        if ( $groupRule.IsDuplicateRule( $global:STIGSettings ))
        {
            $groupRule.SetDuplicateTitle()
        }
    }
    return $groupRule
}
#endregion
