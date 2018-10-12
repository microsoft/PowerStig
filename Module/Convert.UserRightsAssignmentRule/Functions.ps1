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

    if ( [UserRightRule]::HasMultipleRules( $StigRule.rule.Check.'check-content' ) )
    {
        [string[]] $splitRules = [UserRightRule]::SplitMultipleRules( $StigRule.rule.Check.'check-content' )
        $userRightRules = @()
        [int] $byte = 97
        [string] $ruleId = $StigRule.id
        foreach ( $splitRule in $splitRules )
        {
            $StigRule.id = "$($ruleId).$([CHAR][BYTE]$byte)"
            $StigRule.rule.Check.'check-content' = $splitRule
            $userRightRules += [UserRightRule]::New( $StigRule )
            $byte++
        }
        return $userRightRules
    }
    else
    {
        return [UserRightRule]::New( $StigRule )
    }
}

#endregion
