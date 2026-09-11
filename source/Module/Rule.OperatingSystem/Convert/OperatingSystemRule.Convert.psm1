# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\..\Common\Common.psm1
using module .\..\OperatingSystemRule.psm1

class OperatingSystemRuleConvert : OperatingSystemRule
{
    OperatingSystemRuleConvert ()
    {
    }

    OperatingSystemRuleConvert ([xml.xmlelement] $XccdfRule) : base ($XccdfRule, $true)
    {
        $this.SetRequiredEdition()
        $this.SetRequiredArchitecture()
        $this.SetDomainJoinedOnly()
        if ($this.ConversionStatus -eq 'pass')
        {
            $this.SetDuplicateRule()
        }
        $this.SetDscResource()
    }

    [void] SetRequiredEdition()
    {
        $edition = [regex]::Match(
            $this.RawString,
            'If\s+"Edition"\s+is not\s+"(?<Edition>[^"]+)"',
            [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
        ).Groups['Edition'].Value

        if (-not $this.SetStatus($edition))
        {
            $this.RequiredEdition = $edition
        }
    }

    [void] SetRequiredArchitecture()
    {
        $architecture = [regex]::Match(
            $this.RawString,
            'If\s+"System type"\s+is not\s+"(?<Architecture>\d+-bit)\s+operating system',
            [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
        ).Groups['Architecture'].Value

        if (-not $this.SetStatus($architecture))
        {
            $this.RequiredArchitecture = $architecture
        }
    }

    [void] SetDomainJoinedOnly()
    {
        if
        (
            $this.RawString -match 'domain-joined systems' -and
            $this.RawString -match 'For standalone systems, this is NA'
        )
        {
            $this.DomainJoinedOnly = $true
        }
        else
        {
            [void] $this.SetStatus($null)
        }
    }

    [void] SetDscResource()
    {
        if ($this.ConversionStatus -eq 'pass' -and $null -eq $this.DuplicateOf)
        {
            $this.DscResource = 'Script'
        }
        else
        {
            $this.DscResource = 'None'
        }
    }

    static [bool] Match([string] $CheckContent)
    {
        return (
            $CheckContent -match 'Verify domain-joined systems are using' -and
            $CheckContent -match 'If "Edition" is not' -and
            $CheckContent -match 'If "System type" is not' -and
            $CheckContent -match 'For standalone systems, this is NA'
        )
    }
}