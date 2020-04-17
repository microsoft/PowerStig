# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\..\Common\Common.psm1
using module .\..\VsphereVssSecurityRule.psm1

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
        Convert the contents of an xccdf check-content element into a Vsphere object
    .DESCRIPTION
        The VsphereRule class is used to extract the Vsphere settings
        from the check-content of the xccdf. Once a STIG rule is identified a
        Vsphere rule, it is passed to the VsphereRule class for parsing
        and validation.
#>
Class VsphereVssSecurityRuleConvert : VsphereVssSecurityRule
{
    <#
        .SYNOPSIS
            Empty constructor for SplitFactory
    #>
    VsphereVssSecurityRuleConvert ()
    {
    }

    <#
        .SYNOPSIS
            Converts an xccdf stig rule element into a Vsphere Rule
        .PARAMETER XccdfRule
            The STIG rule to convert
    #>
    VsphereVssSecurityRuleConvert ([xml.xmlelement] $XccdfRule) : Base ($XccdfRule, $true)
    {
        $fixText = [VsphereVssSecurityRule]::GetFixText($XccdfRule)
        $rawString = $fixText

        $this.SetVsphereForgedTransmits($rawString)
        $this.SetVsphereMacChanges($rawString)
        $this.SetVsphereAllowPromiscuous($rawString)
        $this.SetDscResource()
    }

    # Methods

    [void] SetVsphereForgedTransmits([string[]] $rawString)
    {
        $thisVsphereForgedTransmits = Get-VsphereForgedTransmits -Rawstring $rawstring
        if (-not [String]::IsNullOrEmpty($thisVsphereForgedTransmits))
        {
            $this.set_ForgedTransmits($thisVsphereForgedTransmits)
        }
    }

    [void] SetVsphereMacChanges([string[]] $rawString)
    {
        $thisVsphereMacChanges = Get-VsphereMacChanges -Rawstring $rawstring
        if (-not [String]::IsNullOrEmpty($thisVsphereMacChanges))
        {
            $this.set_MacChanges($thisVsphereMacChanges)
        }
    }

    [void] SetVsphereAllowPromiscuous([string[]] $rawString)
    {
        $thisVsphereAllowPromiscuous = Get-VsphereAllowPromiscuous -Rawstring $rawstring
        if (-not [String]::IsNullOrEmpty($thisVsphereAllowPromiscuous))
        {
            $this.set_AllowPromiscuous($thisVsphereAllowPromiscuous)
        }
    }

    hidden [void] SetDscResource ()
    {
        if($null -eq $this.DuplicateOf)
        {
            $this.DscResource = 'VMHostVssSecurity'
        }
        else
        {
            $this.DscResource = 'None'
        }
    }


    static [bool] Match ([string] $CheckContent)
    {
        if($CheckContent-match 'Get-VirtualSwitch')
        {
            return $true
        }
        return $false
    }
}
