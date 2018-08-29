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
    $regex = $fileContentRegex.BetweenAllQuotes -f [char]8220, [char]39, [char]8221
    $regexToRemove = $fileContentRegex.RegexToRemove -f [char]8220, [char]8221, [char]39
    
    foreach ($line in $checkContent)
    {
        $matchResult = $line | Select-String -Pattern $regex -AllMatches

        <# Fix added below is temporary to distguish between JRE and Firefox filter sets.  
        Long-term fix needed like a paramerized script or script name to execute for filtering 
        to support different filter sets.  Using -and/-or creates conflicts between technolgies #>

        $lineResult = $matchResult.Matches | Where-Object -FilterScript {
            if($checkContent -match 'JRE') 
                    {
                        $PSItem.Value -match '=' -or $PSItem.Value -match '.locked'
                    } 
                    else 
                    {
                        $PSItem.Value -notmatch 'about:config'
                    }
            }
        
        <# Fix added below is temporary to distguish between JRE and Firefox parsing.  
        Long-term fix needed like a paramerized script or script name to execute for parsing 
        to support different parsing needs.  Using -and/-or creates conflicts between technolgies #>

        if($lineResult -and $checkContent -match 'deployment' -and ($checkContent -match '=' -or $checkContent -match '.locked'))
        {
            $setting = @()
            $settingNoQuotes = $lineResult[0].Value -replace $regexToRemove, ""
            if($lineResult[0].Value -match '=')
            {
                $setting = $settingNoQuotes.Split('=') | ForEach-Object {
                    New-Object PSObject -Property @{Value=$_}
                }
            }
            
            if($lineResult[0].Value -match '.locked')
            {
                $setting = @($settingNoQuotes, 'true') | ForEach-Object {
                    New-Object PSObject -Property @{Value=$_}
                }
            }
            $lineResult = $setting
        }

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
        if ($lineResult.Count -eq 1 -and ($CheckContent -join '`n') -cmatch $fileContentRegex.TwoTo5CapitalLetters)
        {
            $fileExtensionMatches = $CheckContent | Select-String -Pattern $fileContentRegex.CapitalsEndWithSpaceOrDot5 -AllMatches
            $fileExtensions = $fileExtensionMatches.Matches.Value | Where-Object -FilterScript {$PSItem -cmatch $fileContentRegex.CapitalsEndWithSpaceOrDot4}

            $result += [pscustomobject]@{
                Key   = $lineResult.Value -replace $regexToRemove
                Value = ($fileExtensions -replace $fileContentRegex.RemoveAnyNonWordCharacter) -join ','
            }
        }
    }
    # If array of stings return, if hashtable return unique
    if ($result[0] -is [string])
    {
        return $result
    }
    return ($result | Select-Object -Property Key,Value -Unique)
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
