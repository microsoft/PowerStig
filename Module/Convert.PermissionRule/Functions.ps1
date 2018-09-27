# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
#region Functions
<#
    .SYNOPSIS
        Creates PermissionRules from the xccdf
#>
function ConvertTo-PermissionRule
{
    [CmdletBinding()]
    [OutputType([PermissionRule])]
    param
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
        character to identify it as a child object of a specific STIG setting.
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

<#
    .SYNOPSIS
        Creates a new PermissionRule

    .PARAMETER StigRule
        The xml Stig rule from the XCCDF.
#>
function New-PermissionRule
{
    [CmdletBinding()]
    [OutputType([PermissionRule])]
    param
    (
        [Parameter(Mandatory = $true)]
        [xml.xmlelement]
        $StigRule
    )

    Write-Verbose "[$($MyInvocation.MyCommand.Name)]"
    $permissionRule = [PermissionRule]::New( $StigRule )

    $permissionRule.SetPath()

    $permissionRule.SetForce()

    $permissionRule.SetAccessControlEntry()

    if ( $permissionRule.IsDuplicateRule( $global:stigSettings ) )
    {
        $permissionRule.SetDuplicateTitle()
    }

    return $permissionRule
}

#endregion
