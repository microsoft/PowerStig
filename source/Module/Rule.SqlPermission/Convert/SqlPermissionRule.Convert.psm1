# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\..\Common\Common.psm1
using module .\..\..\Rule\Rule.psm1
using module .\..\SqlPermissionRule.psm1

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
        Convert the contents of an xccdf check-content element into a SqlPermissionRule
    .DESCRIPTION
        The SqlPermissionRule class is used to extract the vulnerability ID's that can
        be set with the SqlServerDsc module from the check-content of the xccdf. 
        Once a STIG rule is identified a SqlServerDsc rule, it is passed to the SqlPermissionRule 
        class for parsing and validation.
#>

class SqlPermissionRuleConvert : SqlPermissionRule
{
    <#
        .SYNOPSIS
            Empty constructor for SplitFactory
    #>
    SqlPermissionRuleConvert ()
    {
    }

    <#
        .SYNOPSIS
            Converts a xccdf stig rule element into a SqlProtocol Rule
        .PARAMETER XccdfRule
            The STIG rule to convert
    #>

    SqlPermissionRuleConvert ([xml.xmlelement] $XccdfRule) : base ($XccdfRule, $true)
    {
        $this.SetName()
        $this.SetPermission()
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

    [void] SetName ()
    {
        $thisName = Set-LoginName -CheckContent $this.RawString

        if (-not $this.SetStatus($thisName))
        {
            $this.set_Name($thisName)
        }
    }

    [void] SetPermission ()
    {
        $thisPermission = Set-Permission -CheckContent $this.rawstring

        if (-not $this.SetStatus($thisPermission))
        {
            $this.set_Permission($thisPermission)
        }
    }

    static [bool] Match ([string] $CheckContent)
    {
        if
        (
            $checkContent -Match 'If both IsClustered and IsHadrEnabled' # V-213934
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
            $this.DscResource = 'SqlPermission'
        }
        else
        {
            $this.DscResource = 'None'
        }
    }
}
