# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\..\Common\Common.psm1
using module .\..\..\Rule\Rule.psm1
using module .\..\SqlServerDscRule.psm1

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
        Convert the contents of an xccdf check-content element into a SqlServerDscRule
    .DESCRIPTION
        The SqlSreverDscRule class is used to extract the vulnerability ID's that can
        be set with the SqlServerDsc module from the check-content of the xccdf. 
        Once a STIG rule is identified a SqlServerDsc rule, it is passed to the SqlServerDscRule 
        class for parsing and validation.
#>

class SQLServerDscRuleConvert : SQLServerDscRule
{
    <#
        .SYNOPSIS
            Empty constructor for SplitFactory
    #>
    SqlServerDscRuleConvert ()
    {
    }

    <#
        .SYNOPSIS
            Converts a xccdf stig rule element into a SQLNetworkDSC Rule
        .PARAMETER XccdfRule
            The STIG rule to convert
    #>

    SqlServerDscRuleConvert ([xml.xmlelement] $XccdfRule) : base ($XccdfRule, $true)
    {
        $this.SetOptionName()
        $this.SetOptionValue()
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

    [void] SetOptionName ()
    {
        $thisOptionName = Get-OptionName -CheckContent $this.RawString

        if (-not $this.SetStatus($thisOptionName))
        {
            $this.set_OptionName($thisOptionName)
        }
    }

    [void] SetOptionValue ()
    {
        $thisOptionValue = Set-OptionValue -CheckContent $this.rawstring

        if (-not $this.SetStatus($thisOptionValue))
        {
            $this.set_OptionValue($thisOptionValue)
        }
    }

    static [bool] Match ([string] $CheckContent)
    {
        if
        (
            $CheckContent -Match "EXEC SP_CONFIGURE 'xp_cmdshell';" -or
            $CheckContent -Match "EXEC SP_CONFIGURE 'clr enabled';" -or
            $CheckContent -Match "WHERE name = 'common criteria compliance enabled'" -or
            $CheckContent -Match "EXEC sp_configure 'filestream access level'" -or
            $CheckContent -Match "EXEC SP_CONFIGURE 'Ole Automation Procedures';" -or
            $CheckContent -Match "EXEC SP_CONFIGURE 'user options';" -or
            $CheckContent -Match "EXEC SP_CONFIGURE 'remote access';" -or
            $CheckContent -Match "EXEC SP_CONFIGURE 'hadoop connectivity';" -or
            $CheckContent -Match "EXEC SP_CONFIGURE 'allow polybase export';" -or
            $CheckContent -Match "EXEC SP_CONFIGURE 'remote data archive';" -or
            $CheckContent -Match "EXEC SP_CONFIGURE 'external scripts enabled';" -or
            $CheckContent -Match "EXEC SP_CONFIGURE 'replication xps';"
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
            $this.DscResource = 'SqlServerConfiguration'
        }
        else
        {
            $this.DscResource = 'None'
        }
    }
}