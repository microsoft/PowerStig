# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\Rule\Rule.psm1

<#
    .SYNOPSIS
        Convert the contents of an xccdf check-content element into an Account Policy object
    .DESCRIPTION
        The AccountPolicyRule class is used to extract the Account Policy Settings
        from the check-content of the xccdf. Once a STIG rule is identifed as an
        Account Policy rule, it is passed to the AccountPolicyRule class for parsing
        and validation.
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

    AccountPolicyRule ([xml.xmlelement] $Rule) : Base ($Rule)
    {
        $this.PolicyName  = $Rule.PolicyName
        $this.PolicyValue = $Rule.PolicyValue
    }
    AccountPolicyRule ([xml.xmlelement] $Rule, [bool] $Convert) : Base ($Rule, $Convert)
    {
        $this.PolicyName  = $Rule.PolicyName
        $this.PolicyValue = $Rule.PolicyValue
    }

    [PSObject] GetExceptionHelp()
    {
        return ([Rule]$this).GetExceptionHelp("{0} = 1")
    }
}
