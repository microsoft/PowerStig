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
        $this.SetDuplicateRule()
        $this.SetDscResource()
    }

    #region Methods

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
