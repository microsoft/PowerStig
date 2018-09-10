# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
#region Functions
<#
    .SYNOPSIS
        Accepts the raw stig string data and converts it to a SPWebApplicationRule object.

    .PARAMETER StigRule
        The xml Stig rule from the XCCDF.
#>
function ConvertTo-SPWebApplicationRule
{
    [CmdletBinding()]
    [OutputType([SPWebApplicationRule])]
    param
    (
        [Parameter(Mandatory = $true)]
        [xml.xmlelement]
        $StigRule
    )

    Write-Verbose "[$($MyInvocation.MyCommand.Name)]"

    $spWebApplicationRules = @()
    $checkStrings = $StigRule.rule.Check.('check-content')

    if ( [SPWebApplicationRule]::HasMultipleRules( $checkStrings ) )
    {
        $splitSPWebApplicationRules = [SPWebApplicationRule]::SplitMultipleRules( $checkStrings )

        [int]$byte = 97
        $id = $StigRule.id
        foreach ($spWebApplicationRule in $splitSPWebApplicationRules)
        {
            $StigRule.id = "$id.$([CHAR][BYTE]$byte)"
            $StigRule.rule.Check.('check-content') = $spWebApplicationRule
            $rule = New-SPWebApplicationRule -StigRule $StigRule
            $spWebApplicationRules += $rule
            $byte ++
        }
    }
    else
    {
        $spWebApplicationRules += ( New-SPWebApplicationRule -StigRule $StigRule )
    }
    return $spWebApplicationRules
}
#endregion
#region Support Functions
<#
    .SYNOPSIS
        Creates a new SPWebApplicationRule

    .PARAMETER StigRule
        The xml Stig rule from the XCCDF.
#>
function New-SPWebApplicationRule
{
    [CmdletBinding()]
    [OutputType([SPWebApplicationRule])]
    param
    (
        [Parameter(Mandatory = $true)]
        [xml.xmlelement]
        $StigRule
    )

    Write-Verbose "[$($MyInvocation.MyCommand.Name)]"

    $spWebApplicationRule = [SPWebApplicationRule]::New( $StigRule )

    # call class methods to do stuff
    $spWebApplicationRule.SetConfigSection()

    $spWebApplicationRule.SetKeyValuePair()

    if ($spWebApplicationRule.IsOrganizationalSetting())
    {
        $spWebApplicationRule.SetOrganizationValueTestString()
    }

    if ($spWebApplicationRule.conversionstatus -eq 'pass')
    {
        if ( $spWebApplicationRule.IsDuplicateRule( $global:stigSettings ))
        {
            $spWebApplicationRule.SetDuplicateTitle()
        }
    }

    $spWebApplicationRule.SetStigRuleResource()

    return $spWebApplicationRule
}
#endregion
