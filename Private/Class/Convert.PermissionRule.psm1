# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

#region Header
using module ..\..\public\Class\PermissionRuleClass.psm1
using module ..\..\public\Class\DocumentRuleClass.psm1
using module ..\..\public\common\enum.psm1
using module .\helperFunctions.psm1
#endregion
#region Main Functions
<#
    .SYNOPSIS
        Creates PermissionRules from the xccdf
#>
function ConvertTo-PermissionRule
{
    [CmdletBinding()]
    [OutputType([PermissionRule])]
    Param
    (
        [Parameter(Mandatory = $true)]
        [xml.xmlelement]
        $StigRule
    )

    <#
        There are several permission rules that define multiple permission paths
        with different permissions in a single rule.
        These need to be split into individual permission objects for DSC to process. Detect them
        before creating the Permission Rule class so that we can append the ID and title with a
        character to identify it as a child object of a specif STIG setting.
    #>
    $permissionRules = @()
    $checkStrings = $StigRule.rule.Check.('check-content')

    if ( [PermissionRule]::HasMultipleRules( $checkStrings ) )
    {
        $splitPermissionEntries = [PermissionRule]::SplitMultipleRules( $checkStrings )

        [int]$byte = 97
        $id = $StigRule.id
        foreach ($splitPermissionEntry in $splitPermissionEntries)
        {
            $StigRule.id = "$id.$([CHAR][BYTE]$byte)"
            $StigRule.rule.Check.('check-content') = $splitPermissionEntry
            $Rule = New-PermissionRule -StigRule $StigRule
            $permissionRules += $Rule
            $byte ++
        }
    }
    else
    {
        $PermissionRules += ( New-PermissionRule -StigRule $StigRule )
    }
    return $permissionRules
}
#endregion
#region Support Functions
function New-PermissionRule
{
    [CmdletBinding()]
    [OutputType([PermissionRule])]
    Param
    (
        [Parameter(Mandatory = $true)]
        [xml.xmlelement]
        $StigRule
    )

    Write-Verbose "[$($MyInvocation.MyCommand.Name)]"
    $permissionRule = [PermissionRule]::New( $StigRule )

    $permissionRule.SetPath()

    $permissionRule.SetForce()

    $permissionRule.SetStigRuleResource()

    $permissionRule.SetAccessControlEntry()

    if ( $permissionRule.IsDuplicateRule( $Global:STIGSettings ) )
    {
        $permissionRule.SetDuplicateTitle()
    }

    return $permissionRule
}
#endregion
