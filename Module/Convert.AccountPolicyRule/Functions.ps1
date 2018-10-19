# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
#region Main Functions
<#
    .SYNOPSIS
       Calls the AccountPolicyRule class to generate an account Policy specific object.
#>
function ConvertTo-AccountPolicyRule
{
    [CmdletBinding()]
    [OutputType([AccountPolicyRule])]
    param
    (
        [Parameter(Mandatory = $true)]
        [xml.xmlelement]
        $StigRule
    )

    Write-Verbose "[$($MyInvocation.MyCommand.Name)]"

    $accountPolicyRule = [AccountPolicyRule]::New( $stigRule )
    $accountPolicyRule.SetStigRuleResource()
    $accountPolicyRule.SetPolicyName()

    if ( $accountPolicyRule.TestPolicyValueForRange())
    {
        $accountPolicyRule.SetPolicyValueRange()
    }
    else
    {
        $accountPolicyRule.SetPolicyValue()
    }

    return $accountPolicyRule
}
#endregion
