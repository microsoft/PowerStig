# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
#region Method Functions
<#
    .SYNOPSIS
        Parses Check-Content element to retrieve the Account Policy name
#>
function Get-AccountPolicyName
{
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string[]]
        $CheckContent
    )

    Write-Verbose "[$($MyInvocation.MyCommand.Name)]"

    $string = Get-SecurityPolicyString -CheckContent $checkContent

    try
    {
        # Pull the Account Policy string from between the quotes in the string
        $accountPolicyName = (Get-TestStringTokenList -String ($string -join ',') -StringTokens)[0]
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Account Policy : $accountPolicyName "
        if ($policyNameFixes.$accountPolicyName)
        {
            $accountPolicyName = $policyNameFixes.$accountPolicyName
        }
        return $accountPolicyName
    }
    catch
    {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Account Policy : Not Found"
        return $null
    }
}

<#
    .SYNOPSIS
        Parses Check-Content element to retrieve the Account Policy value.
#>
function Get-AccountPolicyValue
{
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string[]]
        $CheckContent
    )

    Write-Verbose "[$($MyInvocation.MyCommand.Name)]"

    $string = Get-SecurityPolicyString -CheckContent $checkContent

    try
    {
        $accountPolicyValue = (Get-TestStringTokenList -String ($string -join ',') -StringTokens)[1]
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Account Policy : $accountPolicyValue "
        return $accountPolicyValue
    }
    catch
    {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Account Policy : Not Found"
        return $null
    }
}
#endregion
