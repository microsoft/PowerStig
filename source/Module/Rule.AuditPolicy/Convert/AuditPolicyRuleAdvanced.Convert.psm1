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
class AuditPolicyRuleAdvancedConvert : AuditPolicyRule
{
    <#
        .SYNOPSIS
            Empty constructor for SplitFactory
    #>
    AuditPolicyRuleAdvancedConvert ()
    {
    }

    <#
        .SYNOPSIS
            Converts an xccdf stig rule element into a Audit Policy Rule
        .PARAMETER XccdfRule
            The STIG rule to convert
    #>
    AuditPolicyRuleAdvancedConvert ([xml.xmlelement] $XccdfRule) : base ($XccdfRule, $true)
    {
        $tokens = $this.ExtractProperties()
        $this.SetSubcategory($tokens)
        $this.SetAuditFlag($tokens)
        $this.Ensure = [Ensure]::Present
        $this.SetDuplicateRule()
        $this.SetDscResource()
    }

    <#
        .SYNOPSIS
            Extracts and returns the audit policy settings from the check-content.
        .DESCRIPTION
            This match looks for the policy path and the required audit flag in
            the following format:

            Computer Configuration >> ... >> Audit <Subcategory>.
            If "Audit <Subcategory>" is not set to "<AuditFlag>", this is a finding

            The subcategory is taken from the final line of the RawString (the
            leading "Audit " prefix is dropped), and the audit flag is taken from
            the quoted value in the "is [not] set to" clause.
        .NOTES
            If any rule does not match this pattern, please update the xccdf
            change log file to align to this option.
    #>
    [RegularExpressions.MatchCollection] ExtractProperties ()
    {
        return [regex]::Matches(
            $this.RawString,
            '"(?:Audit\s+)?(?<subcategory>[^"]+)"\s+is(?: not)? set to\s+"(?<auditflag>[^"]+)"'
        )
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
            { $_.Name -eq 'subcategory' }
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
            { $_.Name -eq 'auditflag' }
        ).Value

        if (-not $this.SetStatus($thisAuditFlag))
        {
            $this.set_AuditFlag($thisAuditFlag)
        }
    }

    hidden [void] SetDscResource ()
    {
        if ($null -eq $this.DuplicateOf)
        {
            $this.DscResource = 'AuditPolicySubcategory'
        }
        else
        {
            $this.DscResource = 'None'
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
            $CheckContent -Match ">> Advanced Audit Policy Configuration >>"
        )
        {
            return $true
        }
        return $false
    }
}
