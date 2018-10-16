# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
#region Functions
<#
    .SYNOPSIS
       Calls the GroupRule class to generate an local group specfic object.
#>
function ConvertTo-GroupRule
{
    [CmdletBinding()]
    [OutputType([GroupRule])]
    param
    (
        [Parameter(Mandatory = $true)]
        [xml.xmlelement]
        $stigRule
    )

    $groupRule = [GroupRule]::New( $stigRule )
    $groupRule.SetGroupName()
    $groupRule.SetMembersToExclude()
    $groupRule.SetStigRuleResource()

    if ($groupRule.conversionstatus -eq 'pass')
    {
        if ( $groupRule.IsDuplicateRule( $global:stigSettings ))
        {
            $groupRule.SetDuplicateTitle()
        }
    }
    return $groupRule
}
#endregion
