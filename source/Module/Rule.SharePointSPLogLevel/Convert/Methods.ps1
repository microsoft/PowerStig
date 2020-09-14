# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
#region Method Functions

<#
    .SYNOPSIS
        Checks the string for text that indicates a range of acceptable
        acceptable values are allowed by the STIG.
#>
function Test-OrgRuleRange
{
    [CmdletBinding()]
    [OutputType([bool])]
    param
    (
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string[]]
        $CheckContent
    )

    Write-Verbose "[$($MyInvocation.MyCommand.Name)]"
    $string = $CheckContent
    #$string = Get-SecurityPolicyString -CheckContent $checkContent
    #$string = Get-TestStringTokenList -String $string

    # This array is joined into an or '|' before being evaluated
    $matchList = @(
        '.*(system security plan).*(?:this is a finding\.)'
    )

    if ( $string -match ($matchList -join '|') )
    {
        return $true
    }

    return $false
}

#endregion
