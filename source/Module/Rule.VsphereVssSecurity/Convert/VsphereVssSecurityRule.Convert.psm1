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
        Convert the contents of an xccdf check-content element into a Vsphere Vss Security Rule object
    .DESCRIPTION
        The VsphereVssSecurityRule class is used to extract the VsphereVssSecurityRule settings
        from the check-content of the xccdf. Once a STIG rule is identified a
        VsphereVssSecurity rule, it is passed to the VsphereVssSecurityRule class for parsing
        and validation.
#>
class VsphereVssSecurityRuleConvert : VsphereVssSecurityRule
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
    VsphereVssSecurityRuleConvert ([xml.xmlelement] $XccdfRule) : base ($XccdfRule, $true)
    {
        $fixText = [VsphereVssSecurityRule]::GetFixText($XccdfRule)
        $rawString = $fixText
        $this.SetVsphereForgedTransmits($rawString)
        $this.SetVsphereMacChanges($rawString)
        $this.SetVsphereAllowPromiscuous($rawString)
        $this.SetDscResource()
    }

    # Methods
    <#
    .SYNOPSIS
        Extracts the Vsphere ForgedTransmits settings from the fix text and sets the value
    .DESCRIPTION
        Gets the ForgedTransmits from the xccdf content and sets the value.
        If the value that is returned is not valid, the parser status is
        set to fail.
    #>
    [void] SetVsphereForgedTransmits([string[]] $rawString)
    {
        $thisVsphereForgedTransmits = Get-VsphereForgedTransmits -Rawstring $rawstring
        if (-not [String]::IsNullOrEmpty($thisVsphereForgedTransmits))
        {
            $this.set_ForgedTransmits($thisVsphereForgedTransmits)
        }
    }
    <#
    .SYNOPSIS
        Extracts the Vsphere MacChanges settings from the fix text and sets the value
    .DESCRIPTION
        Gets the MacChanges from the xccdf content and sets the value.
        If the value that is returned is not valid, the parser status is
        set to fail.
    #>
    [void] SetVsphereMacChanges([string[]] $rawString)
    {
        $thisVsphereMacChanges = Get-VsphereMacChanges -Rawstring $rawstring
        if (-not [String]::IsNullOrEmpty($thisVsphereMacChanges))
        {
            $this.set_MacChanges($thisVsphereMacChanges)
        }
    }
    <#
    .SYNOPSIS
        Extracts the Vsphere AllowPromiscuous settings from the fix text and sets the value
    .DESCRIPTION
        Gets the AllowPromiscuous from the xccdf content and sets the value.
        If the value that is returned is not valid, the parser status is
        set to fail.
    #>
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
        if ($null -eq $this.DuplicateOf)
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
        if ($CheckContent-match 'Get-VirtualSwitch')
        {
            return $true
        }
        return $false
    }
}
