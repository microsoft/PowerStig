# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\..\Common\Common.psm1
using module .\..\CipherSuitesRule.psm1

$exclude = @($MyInvocation.MyCommand.Name,'Template.*.txt')
$supportFileList = Get-ChildItem -Path $PSScriptRoot -Exclude $exclude
foreach ($supportFile in $supportFileList)
{
    Write-Verbose "Loading $($supportFile.FullName)"
    . $supportFile.FullName
}

# Header

<#
    .SYNOPSIS
        Identifies and extracts the Security Option details from an xccdf rule.
    .DESCRIPTION
        The class is used to convert the rule check-content element into an
        Security Option object. The rule content is parsed to identify it as a
        Security Option rule. The configuration details are then extracted and
        validated before returning the object.
#>
class CipherSuitesRuleConvert : CipherSuitesRule
{
    <#
        .SYNOPSIS
            Empty constructor for SplitFactory
    #>
    CipherSuitesRuleConvert ()
    {
    }

    <#
        .SYNOPSIS
            Converts a xccdf stig rule element into a SharePoint Diagnostic provider Rule
        .PARAMETER XccdfRule
            The STIG rule to convert
    #>
    CipherSuitesRuleConvert ([xml.xmlelement] $XccdfRule) : base ($XccdfRule, $true)
    {
        $this.SetCipherSuitesOrder()	
        $this.SetDuplicateRule()
        $this.SetDscResource()
    }

    #region Methods

        <#
        .SYNOPSIS
            Sets the Security Option name that was extracted from the xccdf.
        .DESCRIPTION
            Gets the Security Option name token from the regular expression match
            group and sets the policy Name. If the named group is null, the
            convert status is set to fail.
    #>
    [void] SetCipherSuitesOrder ()
    {
        if ($this.OrgRuleContainsRange())
        {
            $this.SetOrganizationValue()
        }
    }

    <#
        .SYNOPSIS
            Looks for a range of values defined in the rule.
        .DESCRIPTION
            A regular expression is applied to the rule to look for key words
            and sentence structures that define a list of valid values. If a
            range is detected the test returns true and false if not.
    #>
    [bool] OrgRuleContainsRange ()
    {
        if (Test-OrgRuleRange -CheckContent $this.SplitCheckContent)
        {
            return $true
        }
        return $false
    }
    
    <#
        .SYNOPSIS
            Sets the organizational value with the correct range.
        .DESCRIPTION
            The range of valid values is enforced in the organizational settings
            with a PowerShell expression. The range of values are extracted and
            converted into a PS expression that is evaluated when the rule is
            loaded. For example, if a value is allowed to be between 1 and 3,
            the user provided org setting will be evaluated to ensure that they
            are within policy guide lines and throw an error if not.
    #>
    [void] SetOrganizationValue ()
    {
        $this.set_OrganizationValueRequired($true)

        $thisValueTestString = "'{0}' 'must be an array of cipher suites that are not DES or RC4'"

        if (-not $this.SetStatus($thisValueTestString))
        {
            $this.set_OrganizationValueTestString($thisValueTestString)
        }
    }

    hidden [void] SetDscResource ()
    {
        if ($null -eq $this.DuplicateOf)
        {
            $this.DscResource = 'CipherSuites'
        }
        else
        {
            $this.DscResource = 'None'
        }
    }

    <#
        .SYNOPSIS
            looks for keywords that represent the correct rule
        .DESCRIPTION
            Is used to match this rule to the apporpriate STIG at compile time
    #>
    static [bool] Match ([string] $CheckContent)
    {
        return ($CheckContent -Match ".*SSL Configuration Settings.*SSL Cipher Suite Order.*" -or $CheckContent -Match ".*SSL Cipher Suite Order.*Enabled.*this is a finding.")
    }
    #endregion
}
