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
        Convert the contents of an xccdf check-content element into a Vsphere Port Group Security Rule object
    .DESCRIPTION
        The VspherePortGroupSecurityRule class is used to extract the Vsphere Port Group Security settings
        from the check-content of the xccdf. Once a STIG rule is identified a
        VspherePortGroupSecurity rule, it is passed to the VspherePortGroupSecurityRule class for parsing
        and validation.
#>
class VspherePortGroupSecurityRuleConvert : VspherePortGroupSecurityRule
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
    VspherePortGroupSecurityRuleConvert ([xml.xmlelement] $XccdfRule) : base ($XccdfRule, $true)
    {
        $fixText = [VspherePortGroupSecurityRule]::GetFixText($XccdfRule)
        $rawString = $fixText
        $this.SetVsphereForgedTransmitsInherited($rawString)
        $this.SetVsphereMacChangesInherited($rawString)
        $this.SetVsphereAllowPromiscuousInherited($rawString)
        $this.SetDscResource()
    }

    # Methods
    <#
    .SYNOPSIS
        Extracts the ForgedTransmitInherited boolean from the fix text and sets the value
    .DESCRIPTION
        Gets the boolean from the xccdf content and sets the value.
        If the value that is returned is not valid, the parser status is
        set to fail.
    #>
    [void] SetVsphereForgedTransmitsInherited([string[]] $rawString)
    {
        $thisVsphereForgedTransmitsInherited = Get-VsphereForgedTransmitsInherited -Rawstring $rawstring
        if (-not [String]::IsNullOrEmpty($thisVsphereForgedTransmitsInherited))
        {
            $this.set_ForgedTransmitsInherited($thisVsphereForgedTransmitsInherited)
        }
    }
    <#
    .SYNOPSIS
        Extracts the MacChangesInherited boolean from the fix text and sets the value
    .DESCRIPTION
        Gets the boolean from the xccdf content and sets the value.
        If the value that is returned is not valid, the parser status is
        set to fail.
    #>
    [void] SetVsphereMacChangesInherited([string[]] $rawString)
    {
        $thisVsphereMacChangesInherited = Get-VsphereMacChangesInherited -Rawstring $rawstring
        if (-not [String]::IsNullOrEmpty($thisVsphereMacChangesInherited))
        {
            $this.set_MacChangesInherited($thisVsphereMacChangesInherited)
        }
    }
    <#
    .SYNOPSIS
        Extracts the AllowPromiscuousInherited boolean from the fix text and sets the value
    .DESCRIPTION
        Gets the boolean from the xccdf content and sets the value.
        If the value that is returned is not valid, the parser status is
        set to fail.
    #>
    [void] SetVsphereAllowPromiscuousInherited([string[]] $rawString)
    {
        $thisVsphereAllowPromiscuousInherited = Get-VsphereAllowPromiscuousInherited -Rawstring $rawstring
        if (-not [String]::IsNullOrEmpty($thisVsphereAllowPromiscuousInherited))
        {
            $this.set_AllowPromiscuousInherited($thisVsphereAllowPromiscuousInherited)
        }
    }

    hidden [void] SetDscResource ()
    {
        if ($null -eq $this.DuplicateOf)
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
        if ($CheckContent-match 'Get-VirtualPortGroup')
        {
            return $true
        }
        return $false
    }
}
