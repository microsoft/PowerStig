# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\..\Common\Common.psm1
using module .\..\AuditPolicyRule.psm1
using namespace System.Text
# Header

<#
    .SYNOPSIS
        Converts the xccdf check-content element into an audit policy object.
#>
Class AuditPolicyRuleConvert : AuditPolicyRule
{
    <#
        .SYNOPSIS
            Default constructor
        .DESCRIPTION
            Converts an xccdf stig rule element into a AuditPolicyRule
        .PARAMETER XccdfRule
            The STIG rule to convert
    #>
    AuditPolicyRuleConvert ([xml.xmlelement] $XccdfRule) : Base ($XccdfRule, $true)
    {
        $tokens = $this.Extract()
        $this.SetSubcategory($tokens)
        $this.SetAuditFlag($tokens)
        $this.Ensure = [Ensure]::Present
        $this.DscResource = 'AuditPolicySubcategory'
    }

    <#
        .SYNOPSIS
            Returns the named audit policy settings from the check-content
    #>
    [RegularExpressions.MatchCollection] Extract ()
    {
        $regex = [regex]::Matches(
            $this.RawString,
            '(?:(?:\w+(?:\s|\/))+(?:(?:>|-)>(?:\s+)?))(?<subcategory>(?:\w+\s)+)(?:-(?:\s+)?)(?<auditflag>(?:\w+)+)'
        )

        return $regex
    }

    <#
        .SYNOPSIS
            Set the subcategory name
        .DESCRIPTION
            Set the subcategory value. If the returned audit policy subcategory
            is not valid, the parser status is set to fail.
    #>
    [void] SetSubcategory ([RegularExpressions.MatchCollection] $Regex)
    {
        $thisSubcategory = $regex.Groups.Where(
            {$_.Name -eq 'subcategory'}
        ).Value

        if (-not $this.SetStatus($thisSubcategory))
        {
            $this.set_Subcategory($thisSubcategory.trim())
        }
    }

    <#
        .SYNOPSIS
            Set the subcategory flag
        .DESCRIPTION
            Set the subcategory flag. If the returned audit policy subcategory
            is not valid, the parser status is set to fail.
    #>
    [void] SetAuditFlag ([RegularExpressions.MatchCollection] $Regex)
    {
        $thisAuditFlag = $Regex.Groups.Where(
            {$_.Name -eq 'auditflag'}
        ).Value

        if (-not $this.SetStatus($thisAuditFlag))
        {
            $this.set_AuditFlag($thisAuditFlag)
        }
    }

    <#
        .SYNOPSIS
            Checks if a rule matches an audit policy setting.
    #>
    static [bool] Match ([string] $CheckContent)
    {
        if
        (
            $CheckContent -Match "\bAuditpol\b" -and
            $CheckContent -NotMatch "resourceSACL"
        )
        {
            return $true
        }
        return $false
    }
}
