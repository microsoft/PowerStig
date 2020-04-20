# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\..\Common\Common.psm1
using module .\..\VsphereServiceRule.psm1

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
Class VsphereServiceRuleConvert : VsphereServiceRule
{
    <#
        .SYNOPSIS
            Empty constructor for SplitFactory
    #>
    VsphereServiceRuleConvert ()
    {
    }

    <#
        .SYNOPSIS
            Converts an xccdf stig rule element into a Vsphere Rule
        .PARAMETER XccdfRule
            The STIG rule to convert
    #>
    VsphereServiceRuleConvert ([xml.xmlelement] $XccdfRule) : Base ($XccdfRule, $true)
    {
        $this.SetKey()
        $this.SetPolicy()
        $this.SetDscResource()
    }

    # Methods
    <#
    .SYNOPSIS
        Extracts the advanced settings key value pair from the check-content and sets the values
    .DESCRIPTION
        Gets the key value pair from the xccdf content and sets the value.
        If the value that is returned is not valid, the parser status is
        set to fail.
    #>
    [void] SetKey ()
    {
        $thisKey = Get-VsphereServiceKey -CheckContent $this.SplitCheckContent
        $this.set_Key($thisKey)
    }

        <#
    .SYNOPSIS
        Extracts the advanced settings key value pair from the check-content and sets the values
    .DESCRIPTION
        Gets the key value pair from the xccdf content and sets the value.
        If the value that is returned is not valid, the parser status is
        set to fail.
    #>
    [void] SetPolicy ()
    {
        $thisPolicy = Get-VsphereServicePolicy -CheckContent $this.SplitCheckContent
        $this.set_Policy($thisPolicy[0])
        $this.set_Running($thisPolicy[1])
    }


    hidden [void] SetDscResource ()
    {
        if ($null -eq $this.DuplicateOf)
        {
            $this.DscResource = 'VMHostService'
        }
        else
        {
            $this.DscResource = 'None'
        }
    }


    static [bool] Match ([string] $CheckContent)
    {
        if ($CheckContent-match 'Get-VMHostService')
        {
            return $true
        }
        return $false
    }
}
