# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

#region Header
using module ..\..\Public\Class\AccountPolicyRuleClass.psm1
using module ..\..\Public\Common\enum.psm1
using module .\helperFunctions.psm1
. $PSScriptRoot\..\..\Public\Common\data.ps1
#endregion
#region Main Functions
<#
    .SYNOPSIS
       Calls the AccountPolicyRule class to generate an account Policy specic object.
#>
function ConvertTo-AccountPolicyRule
{
    [CmdletBinding()]
    [OutputType([AccountPolicyRule])]
    Param
    (
        [parameter(Mandatory = $true)]
        [xml.xmlelement]
        $StigRule
    )

    Write-Verbose "[$($MyInvocation.MyCommand.Name)]"

    $accountPolicyRule = [AccountPolicyRule]::New( $StigRule )
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
