# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

<#
    .SYNOPSIS
        Retreives the nxFileLineContainsLine from the check-content element in the xccdf

    .PARAMETER FixText
        Specifies the FixText element in the xccdf
#>
function Get-nxFileLineContainsLine
{
    [CmdletBinding()]
    [OutputType([string[]])]
    param
    (
        [Parameter(Mandatory = $true)]
        [string[]]
        $CheckContent
    )

    Write-Verbose "[$($MyInvocation.MyCommand.Name)]"
    try
    {
        $fileContainsLinePattern = '{0}{1}' -f $regularExpression.nxFileLineFilePath, $regularExpression.nxFileLineContainsLine
        $rawString = $CheckContent -join "`n"
        if ($rawString -match $fileContainsLinePattern)
        {
            $matchResults = $Matches['setting'] -split "`n"
            $results = @()
            foreach ($line in $matchResults)
            {
                if
                (
                    [string]::IsNullOrEmpty($line) -eq $false -and
                    $line -notmatch $regularExpression.nxFileLineContainsLineExclude
                )
                {
                    $results += $line -replace '\s{2,}', ' '
                }
            }
        }

        return $results
    }
    catch
    {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] nxFileLineContainsLine : Not Found"
        return $null
    }
}

<#
    .SYNOPSIS
        Retreives the nxFileLineFilePath from the check-content element in the xccdf

    .PARAMETER FixText
        Specifies the check-content element in the xccdf
#>
function Get-nxFileLineFilePath
{
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $CheckContent
    )

    try
    {
        $null = $CheckContent -match $regularExpression.nxFileLineFilePath
        return $Matches['filePath']
    }
    catch
    {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] nxFileLineFilePath : Not Found"
        return $null
    }
}

<#
    .SYNOPSIS
        Retreives the nxFileLineDoesNotContainPattern from the
        check-content element in the xccdf

    .PARAMETER FixText
        Specifies the check-content element in the xccdf
#>
function Get-nxFileLineDoesNotContainPattern
{
    [CmdletBinding()]
    [OutputType([string])]
    param()

    try
    {
        $results = @()
        foreach ($line in $this.ContainsLine)
        {
            if ($doesNotContainPattern.ContainsKey($line))
            {
                $results += $doesNotContainPattern[$line]
            }
            else
            {
                # This could be expanded upon in the future, dynamically creating the DoesNotContainPattern property.
                $results += $null
            }
        }
    }
    catch
    {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] nxFileLineDoesNotContainPattern : Not Found"
        return $null
    }

    return $results
}

<#
    .SYNOPSIS
        There are several rules that publish multiple FileLine settings in a single rule.
        This function will check for multiple entries.

    .PARAMETER CheckContent
        The standard check content string to look for duplicate entries.
#>
function Test-nxFileLineMultipleEntries
{
    [CmdletBinding()]
    [OutputType([bool])]
    param
    (
        [Parameter(Mandatory = $true)]
        [psobject]
        $CheckContent
    )

    $filePath = $CheckContent | Select-String -Pattern $regularExpression.nxFileLineFilePath -AllMatches
    $filePathCount = @()
    foreach ($path in $filePath.Matches)
    {
        $filePathCount += $path.Groups['filePath'].Value
    }

    $filePathUniqueCount = $filePathCount | Select-Object -Unique | Measure-Object
    if ($filePathUniqueCount.Count -gt 1)
    {
        return $true
    }

    $splitCheckContent = Split-nxFileLineMultipleEntries -CheckContent $CheckContent
    if ($splitCheckContent.Count -gt 1)
    {
        return $true
    }

    return $false
}

<#
    .SYNOPSIS
        There are several rules that publish multiple FileLine settings in a single rule.
        This function will split multiple entries.

    .PARAMETER CheckContent
        The standard check content string to look for duplicate entries.
#>
function Split-nxFileLineMultipleEntries
{
    [CmdletBinding()]
    [OutputType([System.Collections.ArrayList])]
    param
    (
        [Parameter(Mandatory = $true)]
        [psobject]
        $CheckContent
    )

    $splitCheckContent = @()

    # Split CheckContent based on File Path:
    [array] $splitFilePathLineNumber = ($CheckContent | Select-String -Pattern $regularExpression.nxFileLineFilePath).LineNumber

    # Header for the rule should start at 0 through the first detected file path subtract 2 since Select-String LineNumber is not 0 based
    $headerLineRange = 0..($splitFilePathLineNumber[0] - 2)
    $headerFileLine = $CheckContent[$headerLineRange]

    # Footer should start from the last detected "If" to the end of CheckContent
    [array] $footerDetection = ($CheckContent | Select-String -Pattern $regularExpression.nxFileLineFooterDetection).LineNumber
    $footerLineRange = ($footerDetection[-1] - 1)..($CheckContent.Count - 1)
    $footerFileLine = $CheckContent[$footerLineRange]

    # Putting it all together and returning separate entries to the next loop
    for ($i = 0; $i -lt $splitFilePathLineNumber.Count; $i++)
    {
        $splitFilePathStringBuilder = New-Object -TypeName System.Text.StringBuilder
        foreach ($headerLine in $headerFileLine)
        {
            [void] $splitFilePathStringBuilder.AppendLine($headerLine)
        }

        # If the index is equal to the 0 based array count then we are at the list item and the range is calculated from the footer
        if ($i -eq ($splitFilePathLineNumber.Count - 1))
        {
            $splitFileLineContentRange = ($splitFilePathLineNumber[$i] - 1)..($footerLineRange[0] - 1)
        }
        else
        {
            # Determine start of next rule and subtract by 2 since Select-String LineNumber is not 0 based
            $splitFileLineContentRange = ($splitFilePathLineNumber[$i] - 1)..($splitFilePathLineNumber[$i + 1] - 2)
        }

        # Insert the split rule contents and add the footer\, then store the string in the collection
        foreach ($line in $CheckContent[$splitFileLineContentRange])
        {
            [void] $splitFilePathStringBuilder.AppendLine($line)
        }

        foreach ($footerLine in $footerFileLine)
        {
            [void] $splitFilePathStringBuilder.AppendLine($footerLine)
        }

        $splitCheckContent += $splitFilePathStringBuilder.ToString()
    }

    # Split modified CheckContent based each File Path Setting:
    $splitEntries = @()
    foreach ($content in $splitCheckContent)
    {
        $fileContainsLine = Get-nxFileLineContainsLine -CheckContent $content
        if ($null -ne $fileContainsLine)
        {
            $checkContentData = $content.Replace(($fileContainsLine -join "`n"), '{0}')
            foreach ($setting in $fileContainsLine)
            {
                $splitEntries += $checkContentData -f $setting
            }
        }
    }

    return $splitEntries
}
