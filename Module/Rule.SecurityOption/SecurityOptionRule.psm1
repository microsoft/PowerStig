# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\Common\Common.psm1
using module .\..\Rule\Rule.psm1
#header

<#
    .SYNOPSIS
        An Account Policy Rule object
    .DESCRIPTION
        The SecurityOptionRule class is used to maange the Account Policy Settings.
    .PARAMETER OptionName
        The security option name
    .PARAMETER OptionValue
        The security option value
#>
Class SecurityOptionRule : Rule
{
    [ValidateNotNullOrEmpty()] [string] $OptionName
    [ValidateNotNullOrEmpty()] [string] $OptionValue <#(ExceptionValue)#>

    SecurityOptionRule ()
    {
    }

    SecurityOptionRule ([xml.xmlelement] $Rule, [bool] $Convert) : Base ($Rule, $Convert)
    {
    }

    <#
        .SYNOPSIS
            Loads PowerSTIG rule from serialized data
    #>
    SecurityOptionRule ([xml.xmlelement] $Rule) : Base ($Rule)
    {
        $this.OptionName = $Rule.OptionName
        if ($Rule.OptionValue)
        {
            $this.OptionValue = $Rule.OptionValue
        }
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
