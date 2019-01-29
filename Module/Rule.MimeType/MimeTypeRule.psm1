# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\Common\Common.psm1
using module .\..\Rule\Rule.psm1
#header

<#
    .SYNOPSIS
        An Account Policy Rule object
    .DESCRIPTION
        The MimeTypeRule class is used to maange the Account Policy Settings.
    .PARAMETER Extension
        The Name of the extension
    .PARAMETER MimeType
        The mime type
    .PARAMETER Ensure
        A present or absent flag
#>
Class MimeTypeRule : Rule
{
    [string] $Extension
    [string] $MimeType
    [string] $Ensure <#(ExceptionValue)#>

    MimeTypeRule () {}

    MimeTypeRule ([xml.xmlelement] $Rule, [bool] $Convert) : Base ($Rule, $Convert) {}

    MimeTypeRule ([xml.xmlelement] $Rule) : Base ($Rule)
    {
        $this.Extension = $Rule.Extension
        $this.MimeType  = $Rule.MimeType
        $this.Ensure    = $Rule.Ensure
    }

    [PSObject] GetExceptionHelp()
    {
        return ([Rule]$this).GetExceptionHelp("{0} = 1")
    }
}
