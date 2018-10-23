# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
#region Functions
<#
    .SYNOPSIS
        Converts rule from STIG Xccdf to a UserRightRule
#>
function ConvertTo-UserRightRule
{
    [CmdletBinding()]
    [OutputType([UserRightRule[]])]
    param
    (
        [Parameter(Mandatory = $true)]
        [xml.xmlelement]
        $StigRule
    )

    Write-Verbose "[$($MyInvocation.MyCommand.Name)]"
    $userRightRules = @()

    if ( [UserRightRule]::HasMultipleRules( $stigRule.rule.Check.'check-content' ) )
    {
        [string[]] $splitRules = [UserRightRule]::SplitMultipleRules( $stigRule.rule.Check.'check-content' )

        [int] $byte = 97
        [string] $ruleId = $stigRule.id
        foreach ( $splitRule in $splitRules )
        {
            $stigRule.id = "$($ruleId).$([CHAR][BYTE]$byte)"
            $stigRule.rule.Check.'check-content' = $splitRule
            $userRightRules += New-UserRightRule -StigRule $stigRule
            $byte++
        }
    }
    else
    {
        $userRightRules += New-UserRightRule -StigRule $stigRule
    }

    return $userRightRules
}
#endregion Main Functions
#region Support Function
function New-UserRightRule
{
    [CmdletBinding()]
    [OutputType([UserRightRule])]
    param
    (
        [Parameter(Mandatory = $true)]
        [xml.xmlelement]
        $StigRule
    )

    $userRightRule = [UserRightRule]::New( $stigRule )
    $userRightRule.SetDisplayName()
    $userRightRule.SetConstant()
    $userRightRule.SetIdentity()
    $userRightRule.SetForce()
    $userRightRule.SetStigRuleResource()

    if ( $userRightRule.IsDuplicateRule( $global:stigSettings ) )
    {
        $userRightRule.SetDuplicateTitle()
    }

    if ( Test-ExistingRule -RuleCollection $global:stigSettings -NewRule $userRightRule )
    {
        $newId = Get-AvailableId -Id $userRightRule.Id
        $userRightRule.set_id( $newId )
    }

    return $userRightRule
}
#endregion
