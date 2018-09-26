# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\Common\Common.psm1
using module .\..\Rule\Rule.psm1

$exclude = @($MyInvocation.MyCommand.Name,'Template.*.txt')
$supportFileList = Get-ChildItem -Path $PSScriptRoot -Exclude $exclude
Foreach ($supportFile in $supportFileList)
{
    Write-Verbose "Loading $($supportFile.FullName)"
    . $supportFile.FullName
}
# Header

<#
    .SYNOPSIS
        Convert the contents of an xccdf check-content element into a WmiRule object
    .DESCRIPTION
        The WmiRule class is used to extract the settings from rules that don't have
        and dedicated method of evaluation from the check-content of the xccdf.
        Once a STIG rule is identified as a WMI rule, it is passed to the WmiRule
        class for parsing and validation.
    .PARAMETER Query
        The WMI class query
    .PARAMETER Property
        The class property
    .PARAMETER Value
        The value the property should be set to
    .PARAMETER Operator
        The PowerShell equivalent operator
#>
Class WmiRule : Rule
{
    [string] $Query
    [string] $Property
    [string] $Value
    [string] $Operator

    <#
        .SYNOPSIS
            Default constructor
        .DESCRIPTION
            Converts a xccdf STIG rule element into a WmiRule
        .PARAMETER StigRule
            The STIG rule to convert
    #>
    WmiRule ( [xml.xmlelement] $StigRule )
    {
        $this.InvokeClass( $StigRule )
    }
}
