# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\..\Common\Common.psm1
using module .\..\..\Rule\Rule.psm1
using module .\..\ProcessMitigationRule.psm1

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
        Convert the contents of an xccdf check-content element into a process
        mitigation object
    .DESCRIPTION
        The ProcessMitigationRule class is used to extract the process mitigation
        settings from the check-content of the xccdf. Once a STIG rule is identified
        a process Mitigation rule, it is passed to the ProcessMitigationRule class
        for parsing and validation.

#>
class ProcessMitigationRuleConvert : ProcessMitigationRule
{
    <#
        .SYNOPSIS
            Empty constructor for SplitFactory
    #>
    ProcessMitigationRuleConvert ()
    {
    }

    <#
        .SYNOPSIS
            Converts a xccdf stig rule element into a Process Mitigation Rule
        .PARAMETER XccdfRule
            The STIG rule to convert
    #>
    ProcessMitigationRuleConvert ([xml.xmlelement] $XccdfRule) : base ($XccdfRule, $true)
    {
        $this.SetMitigationTarget()
        $this.SetMitigationType()
        $this.SetMitigationName()
        $this.SetMitigationValue()

        if ($this.conversionstatus -eq 'pass')
        {
            $this.SetDuplicateRule()
        }
        $this.SetDscResource()
    }

    #region Methods

    <#
        .SYNOPSIS
            Extracts the mitigation target name from the check-content and sets
            the value
        .DESCRIPTION
            Gets the mitigation target name from the xccdf content and sets the
            value. If the mitigation target name that is returned is not valid,
            the parser status is set to fail
    #>
    [void] SetMitigationTarget ()
    {
        $thisMitigationTarget = Get-MitigationTargetName -CheckContent $this.SplitCheckContent

        if (-not $this.SetStatus($thisMitigationTarget))
        {
            $this.set_MitigationTarget($thisMitigationTarget)
        }
    }

    <#
        .SYNOPSIS
            Sets the type of the mitigation
        .DESCRIPTION
            Sets the mitigation target to enabled. If the mitigation target is
            not set to enabled, it is set to disabled
    #>
    [void] SetMitigationType ()
    {
        $mitigationType = Get-MitigationType -CheckContent $this.SplitCheckContent

        if (-not $this.SetStatus($mitigationType))
        {
            $this.set_MitigationType($mitigationType)
        }
    }

    <#
        .SYNOPSIS
            Sets the name of the mitigation
        .DESCRIPTION
            Sets the mitigation target to enabled. If the mitigation target is
            not set to enabled, it is set to disabled
    #>
    [void] SetMitigationName ()
    {
        $mitigationName = Get-MitigationName -CheckContent $this.SplitCheckContent

        if (-not $this.SetStatus($mitigationName))
        {
            $this.set_MitigationName($mitigationName)
        }
    }

        <#
        .SYNOPSIS
            Sets the Value of the mitigation
        .DESCRIPTION
            Sets the mitigation target to enabled. If the mitigation target is
            not set to enabled, it is set to disabled
    #>
    [void] SetMitigationValue ()
    {
        $mitigationValue = Get-MitigationValue -CheckContent $this.SplitCheckContent

        if (-not $this.SetStatus($mitigationValue))
        {
            $this.set_MitigationValue($mitigationValue)
        }
    }

    hidden [void] SetDscResource ()
    {
        if ($null -eq $this.DuplicateOf)
        {
            $this.DscResource = 'ProcessMitigation'
        }
        else
        {
            $this.DscResource = 'None'
        }
    }

    static [bool] Match ([string] $CheckContent)
    {
        if ($CheckContent -Match "Get-ProcessMitigation")
        {
            return $true
        }
        return $false
    }

    <#
        .SYNOPSIS
            Tests if a rule contains multiple checks
        .DESCRIPTION
            Search the rule text to determine if multiple mitigationsare defined
        .PARAMETER MitigationTarget
            The object the mitigation applies to
    #>
    <#{TODO}#> # HasMultipleRules is implemented inconsistently.
    static [bool] HasMultipleRules ([string] $CheckContent)
    {
        return Test-MultipleProcessMitigations -CheckContent ([ProcessMitigationRule]::SplitCheckContent($CheckContent))
    }

    <#
        .SYNOPSIS
            Splits a rule into multiple checks
        .DESCRIPTION
            Once a rule has been found to have multiple checks, the rule needs
            to be split. This method splits a {0} into multiple rules. Each
            split rule id is appended with a dot and letter to keep reporting
            per the ID consistent. An example would be is V-1000 contained 2
            checks, then SplitMultipleRules would return 2 objects with rule ids
            V-1000.a and V-1000.b
        .PARAMETER MitigationTarget
            The object the mitigation applies to
    #>
    static [string[]] SplitMultipleRules ([string] $CheckContent)
    {
       return Split-MultipleProcessMitigations -CheckContent $CheckContent
    }

    #endregion
}
