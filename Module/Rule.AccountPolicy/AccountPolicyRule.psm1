# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\Common\Common.psm1
using module .\..\Rule\Rule.psm1
#header

<#
    .SYNOPSIS
        An Account Policy Rule object
    .DESCRIPTION
        The AccountPolicyRule class is used to maange the Account Policy Settings.
    .PARAMETER PolicyName
        The name of the account policy
    .PARAMETER PolicyValue
        The value the account policy should be set to.
#>
Class AccountPolicyRule : Rule
{
    [string] $PolicyName
    [string] $PolicyValue <#(ExceptionValue)#>

    AccountPolicyRule () {}

    AccountPolicyRule ([xml.xmlelement] $Rule, [bool] $Convert) : Base ($Rule, $Convert) {}

    AccountPolicyRule ([xml.xmlelement] $Rule) : Base ($Rule)
    {
        $this.PolicyName  = $Rule.PolicyName
        $this.PolicyValue = $Rule.PolicyValue
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
