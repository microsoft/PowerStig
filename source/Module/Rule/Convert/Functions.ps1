# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

<#
    .SYNOPSIS
        Returns the RuleType from the modified check content.
    .PARAMETER CheckContent
        The HardCodedRule modified rule text from the check-content
        element in the xccdf.
#>
function Get-HardCodedRuleType
{
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $CheckContent
    )

    $hardCodedRuleTypeRegExPattern = '(?<RuleType>(?<=\().+?(?=\)))'
    $ruleTypeMatch = [regex]::Match($CheckContent, $hardCodedRuleTypeRegExPattern)
    return $ruleTypeMatch.Groups.Item('RuleType').Value
}

<#
    .SYNOPSIS
        Returns the RuleType from the modified check content.
    .PARAMETER CheckContent
        The HardCodedRule modified rule text from the check-content
        element in the xccdf.
#>

function Get-HardCodedRuleProperty
{
    [CmdletBinding()]
    [OutputType([hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $CheckContent
    )

    $hardCodedHashtableRegExPattern = '(?<hashtable>(@\{).*(\}))'
    $ruleTypeHashtable = [regex]::Match($CheckContent, $hardCodedHashtableRegExPattern)
    $scriptblockString = $ruleTypeHashtable.Groups.Item('hashtable').Value
    return [scriptblock]::Create($scriptblockString).Invoke()
}

<#
    .SYNOPSIS
        Splits and returns rule(s) from the modified check content.
    .PARAMETER CheckContent
        The HardCodedRule modified rule text from the check-content
        element in the xccdf.
#>
function Split-HardCodedRule
{
    [CmdletBinding()]
    [OutputType([string[]])]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $CheckContent
    )

    return $CheckContent -split '\<splitRule\>'
}
