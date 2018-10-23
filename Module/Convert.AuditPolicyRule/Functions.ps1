# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
#region Functions
<#
    .SYNOPSIS
        Processes the raw STIG string that has been identifed as an Audit Poilcy configuration. Since
        the auditpolicy is an easier pattern match
#>
function ConvertTo-AuditPolicyRule
{
    [CmdletBinding()]
    [OutputType([AuditPolicyRule])]
    param
    (
        [Parameter(Mandatory = $true)]
        [xml.xmlelement]
        $StigRule
    )

    Write-Verbose "[$($MyInvocation.MyCommand.Name)]"

    $auditPolicyRule = [AuditPolicyRule]::New( $stigRule )

    $auditPolicyRule.SetStigRuleResource()

    $auditPolicyRule.SetSubcategory()

    $auditPolicyRule.SetAuditFlag()

    $auditPolicyRule.SetEnsureFlag( [Ensure]::Present )

    return $auditPolicyRule
}
#endregion
