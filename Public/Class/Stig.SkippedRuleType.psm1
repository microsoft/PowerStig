# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

using module .\..\Class\Common.Enum.psm1

<#
.SYNOPSIS
    This class describes a SkippedRuleType

.DESCRIPTION
    The SkippedRuleType class describes a SkippedRuleType, the collection of Stig rule ids of a specific Stig rule type that should be excluded
    from the Stigs that need to be processed. The SkippedRuleType class instance will move all of the Stig rules under that type into a
    SkippedRule section of the StigData output Xml so that it is documented as having been skipped.

.EXAMPLE
    $skippedRuleType = [SkippedRuleType]::new('AccountPolicyRule')

.NOTES
    This class requires PowerShell v5 or above.
#>

Class SkippedRuleType
{
    #region Properties
    <#
    .DESCRIPTION
        The name of the type of Stig rule
    #>
    [RuleType] $StigRuleType
    #endregion Properties

    #region Constructors
    <#
    .SYNOPSIS
        Parameterless constructor

    .DESCRIPTION
        A parameterless constructor for SkippedRuleType. To be used only for
        build/unit testing purposes as Pester currently requires it in order to test
        static methods on powershell classes

    .RETURN
        SkippedRuleType
    #>
    SkippedRuleType()
    {
        Write-Warning "This constructor is for build testing only."
    }

    <#
    .SYNOPSIS
        Constructor

    .DESCRIPTION
        A constructor for SkippedRuleType. Returns a ready to use instance
        of SkippedRuleType.

    .PARAMETER StigRuleType
        The name of the type of Stig rule from the StigRuleType Enum

    .RETURN
        SkippedRuleType
    #>
    SkippedRuleType([StigRuleType] $StigRuleType)
    {
        $this.StigRuleType = $StigRuleType
    }
    #endregion Constructors

    #region Static Methods
    <#
    .SYNOPSIS
        Converts a provided string array of Stig rule types into a SkippedRuleType array

    .DESCRIPTION
        This method returns an SkippedRuleType array based on the string array provided
        as the parameter.

    .PARAMETER SkippedRules
        A string array of Stig rule types

        [string[]] $SkippedRuleTypeArray =
            @(
            "AccountPolicyRule",
            "AuditPolicyRule",
            "RegistryRule",
            "SecurityOptionRule",
            "ServicePolicy",
            "UserRightRule"
            )

    .RETURN
        SkippedRuleType[]
    #>
    static [SkippedRuleType[]] ConvertFrom ([string[]] $SkippedRuleTypes)
    {
        [System.Collections.ArrayList] $skips = @()

        foreach ($skip in $SkippedRuleTypes)
        {
            try
            {
                $rule = [SkippedRuleType]::new($skip.Trim())
                $skips.Add($rule)
            }
            catch
            {
                throw("$($skip) is not a valid StigRuleType.")
            }
        }

        return $skips
    }
    #endregion Static Methods
}
