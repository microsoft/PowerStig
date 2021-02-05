# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\..\Common\Common.psm1
using module .\..\..\Rule\Rule.psm1
using module .\..\nxFileRule.psm1

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
        The nxFileRuleConvert class is used to extract the Linux file contents
        modification from the check-content of the xccdf. Once a STIG rule is
        identified as a nxFile rule, it is passed to the nxFileRuleConvert
        class for parsing and validation.
#>
class nxFileRuleConvert : nxFileRule
{
    <#
        .SYNOPSIS
            Empty constructor for SplitFactory.
    #>
    nxFileRuleConvert ()
    {
    }

    <#
        .SYNOPSIS
            Converts a xccdf STIG rule element into a nxFileRule.
        .PARAMETER XccdfRule
            The STIG rule to convert.
    #>
    nxFileRuleConvert ([xml.xmlelement] $XccdfRule) : base ($XccdfRule, $true)
    {
        $rawString = $this.RawString
        $this.SetFilePath($rawString)
        $this.SetContents($rawString)

        if ($this.conversionstatus -eq 'pass')
        {
            $this.SetDuplicateRule()
            $this.SetDscResource()
        }
    }

    <#
        .SYNOPSIS
            Extracts the contents from the check-content and sets the value.
        .DESCRIPTION
            Gets the contents from the xccdf content and sets the value. If
            the name that is returned is not valid, the parser status is set to fail.
    #>
    [void] SetContents ([string[]] $CheckContent)
    {
        $contents = Get-nxFileContents -CheckContent $CheckContent

        if (-not $this.SetStatus($contents))
        {
            $this.set_Contents($contents)
        }
    }

    <#
        .SYNOPSIS
            Extracts the file path from the check-content and sets the value.
        .DESCRIPTION
            Gets the file path from the xccdf content and sets the value. If
            the path that is returned is not valid, the parser status is set to fail.
    #>
    [void] SetFilePath ([string] $CheckContent)
    {
        $filePath = Get-nxFileDestinationPath -CheckContent $CheckContent

        if (-not $this.SetStatus($filePath))
        {
            $this.set_FilePath($filePath)
        }
    }

    <#
        .SYNOPSIS
            Match to detect nxFileRule.
    #>
    static [bool] Match ([string] $CheckContent)
    {
        if
        (
            $CheckContent -Match '#\s+(?:cat|grep|more).*/.*/.*(?:grep|).*' -and
            $CheckContent -Match 'Verify\s+the\s+operating\s+system\s+displays\s+the\s+Standard\s+Mandatory\s+DoD\s+Notice\s+and\s+Consent\s+Banner' -and
            $CheckContent -NotMatch 'ESXi'
        )
        {
            return $true
        }

        return $false
    }

    <#
        .SYNOPSIS
            Sets the DSC Resource.
    #>
    hidden [void] SetDscResource ()
    {
        if ($null -eq $this.DuplicateOf)
        {
            $this.DscResource = 'nxFile'
        }
        else
        {
            $this.DscResource = 'None'
        }
    }
}
