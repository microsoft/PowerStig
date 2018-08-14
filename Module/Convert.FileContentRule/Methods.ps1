# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
#region Method Functions
<#
    .SYNOPSIS
        Parses the rawString from the rule to retrieve the Key name and Value
#>
function Get-KeyValuePair
{
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param
    (
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string[]]
        $CheckContent,

        [Parameter()]
        [switch]
        $SplitCheckContent
    )

    $result = @()
    $regex = '({0}|"|{1})[\s\S]*?("|{0}|{1}|{2})' -f [char]8220, [char]39, [char]8221 # (“|"|')[\s\S]*?("|“|'|”)
    $regexToRemove = '"|{0}|{1}|{2}||\s' -f [char]8220, [char]8221, [char]39 # "|“|”|'

    foreach ($line in $checkContent)
    {
        $matchResult = $line | Select-String -Pattern $regex -AllMatches

        $lineResult = $matchResult.Matches | Where-Object -FilterScript {$PSItem.Value -notmatch 'about:config'}

        if ($lineResult.Count -eq 2)
        {
            if ($SplitCheckContent)
            {
                $result += $matchResult.Line
                continue
            }

            $result += [pscustomobject]@{
                Key   = ($lineResult[0].Value -replace $regexToRemove).Trim()
                Value = ($lineResult[1].Value -replace $regexToRemove).Trim()
            }
        }
        # This code address the edge case where rules browser STIGs manage file extensions
        if ($lineResult.Count -eq 1 -and ($CheckContent -join '`n') -cmatch '[A-Z]{2,5}')
        {
            $fileExtensionMatches = $CheckContent | Select-String -Pattern '[A-Z,1-9]{2,5}(\s|\.)' -AllMatches
            $fileExtensions = $fileExtensionMatches.Matches.Value | Where-Object -FilterScript {$PSItem -cmatch '[A-Z,1-9]{2,4}(\s|\.)'}

            $result += [pscustomobject]@{
                Key   = $lineResult.Value -replace $regexToRemove
                Value = (-join $fileExtensions -replace '\.|\s')
            }
        }
    }
    # We use Select-Object -Unique to handle rules that repeat themselves
    return ($result | Select-Object -Unique)
}

<#
    .SYNOPSIS
        Tests for multiple FileContent rules
#>
function Test-MultipleFileContentRule
{
    [CmdletBinding()]
    [OutputType([bool])]
    param
    (
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        [AllowEmptyString()]
        [pscustomobject[]]
        $KeyValuePair
    )

    if ($KeyValuePair.Count -gt 1)
    {
        return $true
    }
    return $false
}
