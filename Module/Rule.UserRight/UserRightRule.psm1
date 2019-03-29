# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\Common\Common.psm1
using module .\..\Rule\Rule.psm1
#header

<#
    .SYNOPSIS
        An Account Policy Rule object
    .DESCRIPTION
        The UserRightRule class is used to maange the Account Policy Settings.
    .PARAMETER DisplayName
        The user right display name
    .PARAMETER Constant
        The user right constant
    .PARAMETER Identity
        The identitys that should have the user right
    .PARAMETER Force
        A flag that replaces the identities vs append
#>
Class UserRightRule : Rule
{
    [ValidateNotNullOrEmpty()] [string] $DisplayName
    [ValidateNotNullOrEmpty()] [string] $Constant
    [ValidateNotNullOrEmpty()] [string] $Identity <#(ExceptionValue)#>
    [bool] $Force = $false

    UserRightRule () { }

    UserRightRule ([xml.xmlelement] $Rule, [bool] $Convert) : Base ($Rule, $Convert) {}

    UserRightRule ([xml.xmlelement] $Rule) : Base ($Rule)
    {
        $this.DisplayName = $Rule.DisplayName
        $this.Constant    = $Rule.Constant
        $this.Identity    = $Rule.Identity
        $this.Force       = $Rule.Force
    }

    [PSObject] GetExceptionHelp()
    {
        return @{
            Value = "Administrators"
            Notes = $null
        }
    }
}
