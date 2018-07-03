# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

#region Header
using module ..\..\public\Class\AuditPolicyRuleClass.psm1
using module ..\..\public\common\enum.psm1
. $PSScriptRoot\..\..\public\common\data.ps1
#endregion
#region Main Functions
<#
    .SYNOPSIS
        Processes the raw STIG string that has been identifed as an Audit Poilcy configuration. Since
        the auditpolicy is an easire patteren match
#>
function ConvertTo-AuditPolicyRule
{
    [CmdletBinding()]
    [OutputType([AuditPolicyRule])]
    Param
    (
        [parameter(Mandatory = $true)]
        [xml.xmlelement]
        $StigRule
    )

    Write-Verbose "[$($MyInvocation.MyCommand.Name)]"

    $auditPolicyRule = [AuditPolicyRule]::New( $StigRule )

    $auditPolicyRule.SetStigRuleResource()

    $auditPolicyRule.SetSubcategory()

    $auditPolicyRule.SetAuditFlag()

    $auditPolicyRule.SetEnsureFlag( [Ensure]::Present )

    return $auditPolicyRule
}
#endregion
