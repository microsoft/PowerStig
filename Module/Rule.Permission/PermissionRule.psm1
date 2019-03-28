# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\Common\Common.psm1
using module .\..\Rule\Rule.psm1
#header

<#
    .SYNOPSIS
        An Account Policy Rule object
    .DESCRIPTION
        The PermissionRule class is used to maange the Account Policy Settings.
    .PARAMETER Path
        The path to the object the permissions apply to
    .PARAMETER AccessControlEntry
        The ACE to be set on the path property
    .PARAMETER Force
        A flag that will overwrite the current ACE in the ACL instead of merge
#>
Class PermissionRule : Rule
{
    [string] $Path
    [object[]] $AccessControlEntry <#(ExceptionValue)#>
    [bool] $Force

    PermissionRule () {}

    PermissionRule ([xml.xmlelement] $Rule, [bool] $Convert) : Base ($Rule, $Convert) {}

    PermissionRule ([xml.xmlelement] $Rule) : Base ($Rule)
    {
        $this.Path               = $Rule.Path
        $this.AccessControlEntry = $Rule.AccessControlEntry
        $this.Force              = $Rule.Force
    }

    [PSObject] GetExceptionHelp()
    {
        return @{
            Value = "15"
            Notes = $null
        }
    }
}
