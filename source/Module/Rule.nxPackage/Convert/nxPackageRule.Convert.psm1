# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\..\Common\Common.psm1
using module .\..\nxPackageRule.psm1

$exclude = @($MyInvocation.MyCommand.Name,'Template.*.txt')
$supportFileList = Get-ChildItem -Path $PSScriptRoot -Exclude $exclude
foreach ($supportFile in $supportFileList)
{
    Write-Verbose "Loading $($supportFile.FullName)"
    . $supportFile.FullName
}

<#
    .SYNOPSIS
        Convert the contents of an xccdf check-content and/or fixtext element
        into a Linux package object.
    .DESCRIPTION
        The nxPackageRuleConvert class is used to extract the Linux Package from
        the check-content of the xccdf. Once a STIG rule is identified as a
        nx Package rule, it is passed to the nxPackageRuleConvert class for
        parsing and validation.
#>
class nxPackageRuleConvert : nxPackageRule
{
    <#
        .SYNOPSIS
            Empty constructor for SplitFactory.
    #>
    nxPackageRuleConvert ()
    {
    }

    <#
        .SYNOPSIS
            Converts a xccdf STIG rule element into a nxPackageRule.
        .PARAMETER XccdfRule
            The STIG rule to convert.
    #>
    nxPackageRuleConvert ([xml.xmlelement] $XccdfRule) : base ($XccdfRule, $true)
    {
        $fixText = [nxPackageRule]::GetFixText($XccdfRule)
        $this.SetPackageName($fixText)
        $this.SetPackageState($fixText)
        if ($this.conversionstatus -eq 'pass')
        {
            $this.SetDuplicateRule()
        }

        $this.SetDscResource()
    }

    <#
        .SYNOPSIS
            Extracts the package name from the check-content and sets the value.
        .DESCRIPTION
            Gets the package name from the xccdf content and sets the value. If
            the name that is returned is not valid, the parser status is set to fail.
    #>
    [void] SetPackageName ([string] $FixText)
    {
        $packageName = Get-nxPackageName -FixText $FixText

        if (-not $this.SetStatus($packageName))
        {
            $this.set_Name($packageName)
        }
    }

    <#
        .SYNOPSIS
            Extracts the package state from the check-content and sets the value.
        .DESCRIPTION
            Gets the package state from the xccdf content and sets the value. If
            the state that is returned is not valid, the parser status is set to fail.
    #>
    [void] SetPackageState ([string] $FixText)
    {
        $packageState = Get-nxPackageState -FixText $FixText

        if (-not $this.SetStatus($packageState))
        {
            $this.set_Ensure($packageState)
        }
    }

    static [bool] Match ([string] $CheckContent)
    {
        if
        (
            $CheckContent -Match 'dpkg -l \w*|dpkg -l \||#\s*yum\s+list\s+installed\s+' -and
            $CheckContent -NotMatch '(?:Verify the|A) file integrity tool' -and
            $CheckContent -NotMatch 'not installed, this is Not Applicable' -and
            $CheckContent -NotMatch 'If "\w*" is installed, check to see if the "\w*" service is active with the following command'
        )
        {
            return $true
        }

        return $false
    }

    <#
        .SYNOPSIS
            Tests if a rule contains multiple checks.
        .DESCRIPTION
            Search the rule text to determine if multiple {0} are defined. For
            possible future use, as of 4.4.0 all STIGs have one package per rule.
        .PARAMETER Name
            The package name from the rule text from the check-content element
            in the xccdf.
    #>
    [bool] HasMultipleRules ()
    {
        return $false
    }

    hidden [void] SetDscResource ()
    {
        if ($null -eq $this.DuplicateOf)
        {
            $this.DscResource = 'nxPackage'
        }
        else
        {
            $this.DscResource = 'None'
        }
    }
}
