# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\Common\Common.psm1
using module .\..\Rule\Rule.psm1
#header

<#
    .SYNOPSIS
        An Account Policy Rule object
    .DESCRIPTION
        The GroupRule class is used to maange the Account Policy Settings.
    .PARAMETER GroupName
        The Name of the group to configure
    .PARAMETER MembersToExclude
        The list of memmbers that are not allowed to be in the group
#>
Class GroupRule : Rule
{
    [string] $GroupName
    [string[]] $MembersToExclude <#(ExceptionValue)#>

    GroupRule () {}

    GroupRule ([xml.xmlelement] $Rule, [bool] $Convert) : Base ($Rule, $Convert) {}

    GroupRule ([xml.xmlelement] $Rule) : Base ($Rule)
    {
        $this.GroupName        = $Rule.GroupName
        $this.MembersToExclude = $Rule.MembersToExclude
    }

    [PSObject] GetExceptionHelp()
    {
        $return = @{
            Value = "15"
            Notes = $null
        }
        return $return
    }
}
