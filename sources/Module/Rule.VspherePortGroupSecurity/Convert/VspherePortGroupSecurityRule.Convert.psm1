# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\..\Common\Common.psm1
using module .\..\VspherePortGroupSecurityRule.psm1

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
Class VspherePortGroupSecurityRuleConvert : VspherePortGroupSecurityRule
{
    <#
        .SYNOPSIS
            Empty constructor for SplitFactory
    #>
    VspherePortGroupSecurityRuleConvert ()
    {
    }

    <#
        .SYNOPSIS
            Converts an xccdf stig rule element into a Vsphere Rule
        .PARAMETER XccdfRule
            The STIG rule to convert
    #>
    VspherePortGroupSecurityRuleConvert ([xml.xmlelement] $XccdfRule) : Base ($XccdfRule, $true)
    {
        $fixText = [VspherePortGroupSecurityRule]::GetFixText($XccdfRule)
        $rawString = $fixText

        $this.SetVsphereForgedTransmitsInherited($rawString)
        $this.SetVsphereMacChangesInherited($rawString)
        $this.SetVsphereAllowPromiscuousInherited($rawString)
        $this.SetDscResource()
    }

    # Methods

    [void] SetVsphereForgedTransmitsInherited([string[]] $rawString)
    {
        $thisVsphereForgedTransmitsInherited = Get-VsphereForgedTransmitsInherited -Rawstring $rawstring
        $this.set_ForgedTransmitsInherited($thisVsphereForgedTransmitsInherited)
    }

    [void] SetVsphereMacChangesInherited([string[]] $rawString)
    {
        $thisVsphereMacChangesInherited = Get-VsphereMacChangesInherited -Rawstring $rawstring
        $this.set_MacChangesInherited($thisVsphereMacChangesInherited)
    }

    [void] SetVsphereAllowPromiscuousInherited([string[]] $rawString)
    {
        $thisVsphereAllowPromiscuousInherited = Get-VsphereAllowPromiscuousInherited -Rawstring $rawstring
        $this.set_AllowPromiscuousInherited($thisVsphereAllowPromiscuousInherited)
    }

    hidden [void] SetDscResource ()
    {
        if($null -eq $this.DuplicateOf)
        {
            $this.DscResource = 'VMHostVssPortGroupSecurity'
        }
        else
        {
            $this.DscResource = 'None'
        }
    }


    static [bool] Match ([string] $CheckContent)
    {
        if($CheckContent-match 'Get-VirtualPortGroup')
        {
            return $true
        }
        return $false
    }
}
