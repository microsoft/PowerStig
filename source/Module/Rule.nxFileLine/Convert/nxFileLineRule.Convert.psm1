# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\..\Common\Common.psm1
using module .\..\nxFileLineRule.psm1

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
        The nxFileLineRuleConvert class is used to extract the Linux file contents
        modification from the check-content of the xccdf. Once a STIG rule is
        identified as a nxFileLine rule, it is passed to the nxFileLineRuleConvert
        class for parsing and validation.
#>
class nxFileLineRuleConvert : nxFileLineRule
{
    <#
        .SYNOPSIS
            Empty constructor for SplitFactory.
    #>
    nxFileLineRuleConvert ()
    {
    }

    <#
        .SYNOPSIS
            Converts a xccdf STIG rule element into a nxFileLineRule.
        .PARAMETER XccdfRule
            The STIG rule to convert.
    #>
    nxFileLineRuleConvert ([xml.xmlelement] $XccdfRule) : base ($XccdfRule, $true)
    {
        $fixText = [nxFileLineRule]::GetFixText($XccdfRule)
        $this.SetContainsLine($fixText)
        $this.SetFilePath($fixText)
        $this.SetDoesNotContainPattern($fixText)
        if ($this.conversionstatus -eq 'pass')
        {
            $this.SetDuplicateRule()
        }

        $this.SetDscResource()
    }

    <#
        .SYNOPSIS
            Extracts the line to be modified from the check-content and sets the value.
        .DESCRIPTION
            Gets the line to be modified from the xccdf content and sets the value. If
            the name that is returned is not valid, the parser status is set to fail.
    #>
    [void] SetContainsLine ([string] $FixText)
    {
        $containsLine = Get-nxFileLineContainsLine -FixText $FixText

        if (-not $this.SetStatus($containsLine))
        {
            $this.set_ContainsLine($containsLine)
        }
    }

    <#
        .SYNOPSIS
            Extracts the file path from the check-content and sets the value.
        .DESCRIPTION
            Gets the file path from the xccdf content and sets the value. If
            the path that is returned is not valid, the parser status is set to fail.
    #>
    [void] SetFilePath ([string] $FixText)
    {
        $filePath = Get-nxFileLineFilePath -FixText $FixText

        if (-not $this.SetStatus($filePath))
        {
            $this.set_FilePath($filePath)
        }
    }

    <#
        .SYNOPSIS
            Extracts the DoesNotContainPattern from the check-content and sets the value.
        .DESCRIPTION
            Gets the DoesNotContainPattern from the xccdf content and sets the value. If
            the DoesNotContainPattern that is returned is not valid, the parser status
            is set to fail.
    #>
    [void] SetDoesNotContainPattern ([string] $FixText)
    {
        $doesNotContainPattern = Get-nxFileLineDoesNotContainPattern -FixText $FixText

        if (-not $this.SetStatus($doesNotContainPattern))
        {
            $this.set_DoesNotContainPattern($doesNotContainPattern)
        }
    }

    static [bool] Match ([string] $CheckContent)
    {
        if ($CheckContent -Match 'If.*"\w*".*commented out.*this is a finding|If.*"\w*".*is missing from.*file.*this is a finding')
        {
            return $true
        }

        return $false
    }

    <#
        .SYNOPSIS
            Tests if a rule contains multiple checks.
        .DESCRIPTION
            Search the rule text to determine if multiple rules are defined.
    #>
    [bool] HasMultipleRules ()
    {
        return $false
    }

    hidden [void] SetDscResource ()
    {
        if ($null -eq $this.DuplicateOf)
        {
            $this.DscResource = 'nxFileLine'
        }
        else
        {
            $this.DscResource = 'None'
        }
    }
}
