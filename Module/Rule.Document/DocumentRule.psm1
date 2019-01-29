# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\Common\Common.psm1
using module .\..\Rule\Rule.psm1
#header

<#
    .SYNOPSIS
        An Account Policy Rule object
    .DESCRIPTION
        The DocumentRule class is used to maange the Account Policy Settings.

#>
Class DocumentRule : Rule
{
     <#(ExceptionValue)#>

    DocumentRule ()
    {
    }

    DocumentRule ([xml.xmlelement] $Rule, [bool] $Convert) : Base ($Rule, $Convert)
    {
    }

    DocumentRule ([xml.xmlelement] $Rule) : Base ($Rule)
    {
        $this.X = $Rule.X
    }

    [PSObject] GetExceptionHelp()
    {
        return ([Rule]$this).GetExceptionHelp("{0} = 1")
    }
}
