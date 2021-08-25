# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\..\Common\Common.psm1
using module .\..\..\Rule\Rule.psm1
using module .\..\SqlProtocolRule.psm1

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
        Convert the contents of an xccdf check-content element into a SqlProtocolRule
    .DESCRIPTION
        The SqlLoginRule class is used to extract the vulnerability ID's that can
        be set with the SqlServerDsc module from the check-content of the xccdf. 
        Once a STIG rule is identified a SqlServerDsc rule, it is passed to the SqlProtocolRule 
        class for parsing and validation.
#>

class SqlProtocolRuleConvert : SqlProtocolRule
{
    <#
        .SYNOPSIS
            Empty constructor for SplitFactory
    #>
    SqlProtocolRuleConvert ()
    {
    }

    <#
        .SYNOPSIS
            Converts a xccdf stig rule element into a SqlProtocol Rule
        .PARAMETER XccdfRule
            The STIG rule to convert
    #>

    SqlProtocolRuleConvert ([xml.xmlelement] $XccdfRule) : base ($XccdfRule, $true)
    {
        $this.SetProtocolName()
        $this.SetEnabled()
        $this.SetDscResource()
    }

    #region Methods

    <#
        .SYNOPSIS
            Extracts the mitigation target name from the check-content and sets
            the value
        .DESCRIPTION
            Gets the mitigation target name from the xccdf content and sets the
            value. If the mitigation target name that is returned is not valid,
            the parser status is set to fail
    #>

    [void] SetProtocolName ()
    {
        $thisProtocolName = Get-ProtocolName -CheckContent $this.RawString

        if (-not $this.SetStatus($thisProtocolName))
        {
            $this.set_ProtocolName($thisProtocolName)
        }
    }

    [void] SetEnabled ()
    {
        $thisEnabled = Set-Enabled -CheckContent $this.rawstring

        if (-not $this.SetStatus($thisEnabled))
        {
            $this.set_Enabled($thisEnabled)
        }
    }

    static [bool] Match ([string] $CheckContent)
    {
        if
        (
            $CheckContent -Match "If Named Pipes is enabled"
        )
        {
            return $true
        }
        
        return $false
    }

    hidden [void] SetDscResource ()
    {
        if ($null -eq $this.DuplicateOf)
        {
            $this.DscResource = 'SqlProtocol'
        }
        else
        {
            $this.DscResource = 'None'
        }
    }
}
