# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\Common\Common.psm1
using module .\..\Rule\Rule.psm1

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
    .PARAMETER MitigationTarget
        The object the mitigation applies to
    .PARAMETER Enable
        A flag to enable the mitigation rule
    .PARAMETER Disable
        A flag to disable the mitigation rule
#>
Class ProcessMitigationRule : Rule
{
    [string] $MitigationTarget
    [string] $Enable
    [string] $Disable

    <#
        .SYNOPSIS
            Default constructor
        .DESCRIPTION
            Converts a xccdf stig rule element into a ProcessMitigationRule
        .PARAMETER StigRule
            The STIG rule to convert
    #>
    hidden ProcessMitigationRule ([xml.xmlelement] $StigRule)
    {
        $this.InvokeClass($StigRule)
        $this.SetMitigationTargetName()
        $this.SetMitigationToEnable()
        if ($this.conversionstatus -eq 'pass')
        {
            if ($this.IsDuplicateRule($global:stigSettings))
            {
                $this.SetDuplicateTitle()
            }
        }
        $this.SetDscResource()
    }

    #region Methods

    static [ProcessMitigationRule[]] ConvertFromXccdf ([xml.xmlelement] $StigRule)
    {
        $ruleList = @()
        $rule = [ProcessMitigationRule]::new($StigRule)
        if ($rule.HasMultipleRules())
        {
            [string[]] $splitRules = $rule.SplitMultipleRules()
            foreach ($splitRule in $splitRules)
            {
                $ruleClone = $rule.Clone()
                $ruleClone.MitigationTarget = $splitRule
                $ruleList += $ruleClone
            }
        }
        else
        {
            $ruleList += $rule
        }

        return $ruleList
    }

    <#
        .SYNOPSIS
            Extracts the mitigation target name from the check-content and sets
            the value
        .DESCRIPTION
            Gets the mitigation target name from the xccdf content and sets the
            value. If the mitigation target name that is returned is not valid,
            the parser status is set to fail
    #>
    [void] SetMitigationTargetName ()
    {
        $thisMitigationTargetName = Get-MitigationTargetName -CheckContent $this.SplitCheckContent

        if (-not $this.SetStatus($thisMitigationTargetName))
        {
            $this.set_MitigationTarget($thisMitigationTargetName)
        }
    }

    <#
        .SYNOPSIS
            Enables the mitigation target
        .DESCRIPTION
            Sets the mitigation target to enabled. If the mitigation target is
            not set to enabled, it is set to disabled
    #>
    [void] SetMitigationToEnable ()
    {
        $thisMitigation = Get-MitigationPolicyToEnable -CheckContent $this.SplitCheckContent

        if (-not $this.SetStatus($thisMitigation))
        {
            $this.set_Enable($thisMitigation)
        }
    }

    <#
        .SYNOPSIS
            Tests if a rule contains multiple checks
        .DESCRIPTION
            Search the rule text to determine if multiple mitigationsare defined
        .PARAMETER MitigationTarget
            The object the mitigation applies to
    #>
    [bool] HasMultipleRules ()
    {
        return (Test-MultipleProcessMitigationRule -MitigationTarget $this.MitigationTarget)
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
    [string[]] SplitMultipleRules ()
    {
        return (Split-ProcessMitigationRule -MitigationTarget $this.MitigationTarget)
    }

    static [bool] Match ([string] $CheckContent)
    {
        if ($CheckContent -Match "Get-ProcessMitigation")
        {
            return $true
        }
        return $false
    }

    hidden [void] SetDscResource ()
    {
        $this.DscResource = 'ProcessMitigation'
    }
    #endregion
}
