# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\..\Common\Common.psm1
using module .\..\VsphereNtpSettingsRule.psm1

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
Class VsphereNtpSettingsRuleConvert : VsphereNtpSettingsRule
{
    <#
        .SYNOPSIS
            Empty constructor for SplitFactory
    #>
    VsphereNtpSettingsRuleConvert ()
    {
    }

    <#
        .SYNOPSIS
            Converts an xccdf stig rule element into a Vsphere Rule
        .PARAMETER XccdfRule
            The STIG rule to convert
    #>
    VsphereNtpSettingsRuleConvert ([xml.xmlelement] $XccdfRule) : Base ($XccdfRule, $true)
    {
        if ($this.IsOrganizationalSetting())
        {
            $this.SetOrganizationValueTestString()
        }
        $this.SetVsphereNtpSettings()
        $this.SetDscResource()
    }

    # Methods
    <#
        .SYNOPSIS
            Tests if and organizational value is required
        .DESCRIPTION
            Tests if and organizational value is required
    #>
    [Boolean] IsOrganizationalSetting ()
    {
        if ([String]::IsNullOrEmpty($this.NtpServer))
        {
            return $true
        }
        else
        {
            return $false
        }
    }

    <#
    .SYNOPSIS
        Set the organizational value
    .DESCRIPTION
        Extracts the organizational value from the key and then sets the value
    #>
    [void] SetOrganizationValueTestString ()
    {
        $thisOrganizationValueTestString = Get-VsphereNtpSettingsOrganizationValueTestString -Id $this.id

        if (-not $this.SetStatus($thisOrganizationValueTestString))
        {
            $this.set_OrganizationValueTestString($thisOrganizationValueTestString)
            $this.set_OrganizationValueRequired($true)
        }
    }


    <#
    .SYNOPSIS
        Extracts the advanced settings key value pair from the check-content and sets the values
    .DESCRIPTION
        Gets the key value pair from the xccdf content and sets the value.
        If the value that is returned is not valid, the parser status is
        set to fail.
    #>
    [void] SetVsphereNtpSettings ()
    {
        $thisVsphereNtpSettings = Get-VsphereNtpSettings -CheckContent $this.SplitCheckContent
        $this.set_NtpServer($thisVsphereNtpSettings)
    }

    hidden [void] SetDscResource ()
    {
        if ($null -eq $this.DuplicateOf)
        {
            $this.DscResource = 'VMHostNtpSettings'
        }
        else
        {
            $this.DscResource = 'None'
        }
    }


    static [bool] Match ([string] $CheckContent)
    {
        if ($CheckContent-match 'Get-VMHostNTPServer')
        {
            return $true
        }
        return $false
    }
}
