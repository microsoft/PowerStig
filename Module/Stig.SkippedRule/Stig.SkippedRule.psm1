# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
# Header

<#
    .SYNOPSIS
        This class describes a SkippedRule

    .DESCRIPTION
        The SkippedRule class describes a SkippedRule, the rule id of a specific Stig rule that should be excluded from the Stigs that need to be
        processed. The SkippedRule class instance will move the specific Stig rule into a SkippedRule section of the StigData output Xml so that
        it is documented as having been skipped.

    .PARAMETER StigRuleId
        The Id of an individual Stig Rule

    .EXAMPLE
        $skippedRule = [SkippedRule]::new('V-1090')

    .NOTES
        This class requires PowerShell v5 or above.
#>
Class SkippedRule
{
    [string] $StigRuleId

    #region Constructor

    <#
        .SYNOPSIS
            DO NOT USE - For testing only

        .DESCRIPTION
            A parameterless constructor for SkippedRule. To be used only for
            build/unit testing purposes as Pester currently requires it in order to test
            static methods on powershell classes
    #>
    SkippedRule ()
    {
        Write-Warning "This constructor is for build testing only."
    }

    <#
        .SYNOPSIS
            A constructor for SkippedRule. Returns a ready to use instance of SkippedRule.

        .DESCRIPTION
            A constructor for SkippedRule. Returns a ready to use instance
            of SkippedRule.

        .PARAMETER StigRuleId
            The Id of an individual Stig Rule
    #>
    SkippedRule ([string] $StigRuleId)
    {
        $this.StigRuleId = $StigRuleId
    }

    #endregion
    #region Static Methods

    <#
        .SYNOPSIS
            Converts a provided string array of Stig rule ids into a SkippedRule array

        .DESCRIPTION
            This method returns an SkippedRule array based on the string array provided
            as the parameter.

        .PARAMETER SkippedRules
            A string array of Stig rule ids

            [string[]] $SkippedRuleArray =
                @(
                "V-1114",
                "V-1115",
                "V-3472.a",
                "V-4108",
                "V-4113",
                "V-8322.b",
                "V-26482",
                "V-26579",
                "V-26580",
                "V-26581"
                )
    #>
    static [SkippedRule[]] ConvertFrom ([string[]] $SkippedRules)
    {
        [System.Collections.ArrayList] $skips = @()

        foreach ($skip in $SkippedRules)
        {
            $rule = [SkippedRule]::new($skip.Trim())
            $skips.Add($rule)
        }

        return $skips
    }

    #endregion
}

# Footer
$exclude = @($MyInvocation.MyCommand.Name,'Template.*.txt')
Foreach ($supportFile in Get-ChildItem -Path $PSScriptRoot -Exclude $exclude)
{
    Write-Verbose "Loading $($supportFile.FullName)"
    . $supportFile.FullName
}
Export-ModuleMember -Function '*' -Variable '*'
