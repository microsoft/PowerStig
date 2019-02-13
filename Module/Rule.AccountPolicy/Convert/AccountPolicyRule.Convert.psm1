# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\..\Common\Common.psm1
using module .\..\AccountPolicyRule.psm1
using namespace System.Text
# Header

<#
    .SYNOPSIS
        Convert the contents of an xccdf check-content element into an Account Policy object
    .DESCRIPTION
        The AccountPolicyRule class is used to extract the Account Policy Settings
        from the check-content of the xccdf. Once a STIG rule is identifed as an
        Account Policy rule, it is passed to the AccountPolicyRule class for parsing
        and validation.
#>
Class AccountPolicyRuleConvert : AccountPolicyRule
{
    <#
        .SYNOPSIS
            Default constructor
        .DESCRIPTION
            Converts a xccdf stig rule element into a AccountPolicyConvert
        .PARAMETER StigRule
            The STIG rule to convert
    #>
    AccountPolicyRuleConvert ([xml.xmlelement] $XccdfRule) : Base ($XccdfRule, $true)
    {

        $tokens = $this.Extract()
        $this.SetPolicyName($tokens)
        if ($this.TestPolicyValueForRange())
        {
            $this.SetPolicyValueRange()
        }
        else
        {
            $this.SetPolicyValue($tokens)
        }
        $this.DscResource = 'AccountPolicy'
    }

    #region Methods

    <#
        .SYNOPSIS
            Returns the named account policy settings from the check-content
    #>
    [RegularExpressions.MatchCollection] Extract ()
    {
        <#
            This match looks for the following patterns
            1. If the "PolicyName" * "Value"
            2. If the value for "PolicyName" * "Value"
            3. If the value for the "PolicyName" * "Value"

            If any rule do not match this pattern, please update the change log
            file to align to one of these options.
        #>
        return [regex]::Matches(
            $this.RawString,
            '(?:If the (?:value for (?:the )?)?")(?<policyName>[^"]+)(?:")[^"]+(?:")(?<policyValue>[^"]+)(?:")'
        )
    }

    <#
        .SYNOPSIS
            Gets the account policy name from the xccdf content and sets the Policy Name.
        .DESCRIPTION
            Gets the account policy name from the xccdf content and sets the Policy Name.
            If the account policy that is returned is not a valid account policy Name, the
            parser status is set to fail.
    #>
    [void] SetPolicyName ([RegularExpressions.MatchCollection] $Regex)
    {
        $thisPolicyName = $Regex.Groups.Where(
            {$_.Name -eq 'policyName'}
        ).Value

        if (-not $this.SetStatus($thisPolicyName))
        {
            $this.set_PolicyName($thisPolicyName)
        }
    }

    <#
        .SYNOPSIS
            Looks for a range of valid values
        .DESCRIPTION
            When a range of valid values is discovered, the range needs to be extracted out
            so. This method tests for ranges in the check-content.
    #>
    [bool] TestPolicyValueForRange ()
    {
        if (Test-SecurityPolicyContainsRange -CheckContent $this.SplitCheckContent)
        {
            return $true
        }
        return $false
    }

    <#
        .SYNOPSIS
            Gets the account policy value from the xccdf content and sets the Policy value.
        .DESCRIPTION
            Gets the account policy value from the xccdf content and sets the Policy value.
            If the value is determined to be invalid, it sets the parser status to failed.
    #>
    [void] SetPolicyValue ([RegularExpressions.MatchCollection] $Regex)
    {
        $thisPolicyValue = $Regex.Groups.Where(
            {$_.Name -eq 'policyValue'}
        ).Value

        if (-not $this.SetStatus($thisPolicyValue))
        {
            $this.set_PolicyValue($thisPolicyValue)
        }
    }

    <#
        .SYNOPSIS
            Sets the organizational value with the correct range.
        .DESCRIPTION
            A range of valid values is supported with PowerShell expressions. If
            a value is allowed to be between 1 and 3, then the PowerShell
            equivalent needs to be applied to the organizational settings list.
    #>
    [void] SetPolicyValueRange ()
    {
        $this.set_OrganizationValueRequired($true)

        $thisPolicyValueTestString = Get-SecurityPolicyOrganizationValueTestString -CheckContent $this.SplitCheckContent

        if (-not $this.SetStatus($thisPolicyValueTestString))
        {
            $this.set_OrganizationValueTestString($thisPolicyValueTestString)
        }
    }

    hidden [void] SetDscResource ()
    {
        $this.DscResource
    }

    static [bool] Match ([string] $CheckContent)
    {
        if($CheckContent -Match 'Navigate to.+Windows Settings\s*(-|>)?>\s*Security Settings\s*(-|>)?>\s*Account Policies')
        {
            return $true
        }
        return $false
    }
    #endregion
}
