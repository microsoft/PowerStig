# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\..\Common\Common.psm1
using module .\..\..\Rule\Rule.psm1
using module .\..\SqlProtocolTcpIpRule.psm1

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
        Convert the contents of an xccdf check-content element into a SqlProtocolTcpIpRule
    .DESCRIPTION
        The SqlProtocolTcpIp class is used to extract the vulnerability ID's that can
        be set with the SqlServerDsc module from the check-content of the xccdf. 
        Once a STIG rule is identified a SqlServerDsc rule, it is passed to the SqlProtocolTcpIpRule 
        class for parsing and validation.
#>

class SqlProtocolTcpIpRuleConvert : SqlProtocolTcpIpRule
{
    <#
        .SYNOPSIS
            Empty constructor for SplitFactory
    #>
    SqlProtocolTcpIpRuleConvert ()
    {
    }

    <#
        .SYNOPSIS
            Converts a xccdf stig rule element into a SqlProtocolTcpIp Rule
        .PARAMETER XccdfRule
            The STIG rule to convert
    #>

    SqlProtocolTcpIpRuleConvert ([xml.xmlelement] $XccdfRule) : base ($XccdfRule, $true)
    {
        $this.SetTcpPort()
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

    [void] SetTcpPort ()
    {
        $thisTcpPort = Get-TcpPort -CheckContent $this.RawString

        if (-not $this.SetStatus($thisTcpPort))
        {
            $this.set_TcpPort($thisTcpPort)
        }
    }

    static [bool] Match ([string] $CheckContent)
    {
        if
        (
            $CheckContent -Match "SQL Server must only use approved network communication libraries, ports, and protocols."
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
            $this.DscResource = 'SqlProtocolTcpIp'
        }
        else
        {
            $this.DscResource = 'None'
        }
    }
}
