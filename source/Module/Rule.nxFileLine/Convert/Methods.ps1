# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

<#
    .SYNOPSIS
        Retrieves the nxFileLineContainsLine from the check-content element in the xccdf

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
        $rawString = $CheckContent -join "`n"
        if
        (
            $rawString -match $regularExpression.nxFileLineContainsLine -or
            $rawString -match $regularExpression.nxFileLineContainsLineYumConf -or
            $rawString -match $regularExpression.nxFileLineContainsLineAuditUbuntu
        )
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
        elseif ($rawString -match 'You are accessing a U.S. Government \(USG\) [^"]+(?<=details.)')
        {
            $results = $matches.Values -replace '\.\r', ".`n"
            $results = $results -replace ':\r', ":`n"
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
        $nxFileLineFilePathAggregate = '{0}|{1}|{2}|{3}|{4}|{5}|{6}' -f
            $regularExpression.nxFileLineFilePathAudit,
            $regularExpression.nxFileLineFilePathAuditUbuntu,
            $regularExpression.nxFileLineFilePathUbuntuBanner,
            $regularExpression.nxFileLineFilePathBannerUbuntu,
            $regularExpression.nxFileLineFilePathTftp,
            $regularExpression.nxFileLineFilePathRescue,
            $regularExpression.nxFileLineFilePath
        $null = $CheckContent -match $nxFileLineFilePathAggregate
        switch ($Matches.Keys)
        {
            {
                $PSItem -eq 'auditPath' -or $PSItem -eq 'auditPathUbuntu'
            }
            {
                return '/etc/audit/rules.d/audit.rules'
            }
            'ubuntuBanner'
            {
                return '/etc/issue'
            }
            'bannerPathUbuntu'
            {
                return $Matches['bannerPathUbuntu']
            }
            'tftpPath'
            {
                return $Matches['tftpPath']
            }
            'rescuePath'
            {
                return $Matches['rescuePath']
            }
            'filePath'
            {
                return $Matches['filePath']
            }
            default
            {
                Write-Verbose "[$($MyInvocation.MyCommand.Name)] nxFileLineFilePath : Not Found"
                return $null
            }
        }
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

    $doesNotContainPatternExclusionRuleId = @(
        'V-71863'
    )

    if ($doesNotContainPatternExclusionRuleId -contains $this.Id)
    {
        return 'PatternNotRequired'
    }

    try
    {
        if ($doesNotContainPattern.ContainsKey($this.ContainsLine))
        {
            $results = $doesNotContainPattern[$this.ContainsLine]
        }

        if
        (
            $results -eq 'DynamicallyGeneratedDoesNotContainPattern' -or
            $doesNotContainPattern.ContainsKey($this.ContainsLine) -eq $false
        )
        {
            <#
                The "Dynamic" DoesNotContainPattern generation takes the containsLine and prefixes it with
                a hash, as well as replaces any spaces with a RegEx \s*.
            #>
            $doesNotContainPattern = $this.ContainsLine -replace '=', '\s*=\s*' -replace '\s+', '\s*'
            $doesNotContainPattern = $doesNotContainPattern.Replace('\s*\s*', '\s*')
            $results = '#\s*{0}' -f $doesNotContainPattern
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
        if ($path.Groups['filePath'].Value -ne '/etc/issue')
        {
            $filePathCount += $path.Groups['filePath'].Value
        }
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

    # Split CheckContent based on File Path or 'sudo auditctl...':
    $splitFilePathPatternAggregate = '{0}|{1}' -f $regularExpression.nxFileLineFilePath, $regularExpression.nxFileLineFilePathAuditUbuntu
    [array] $splitFilePathLineNumber = ($CheckContent | Select-String -Pattern $splitFilePathPatternAggregate).LineNumber

    #checking against $splitFilePathLineNumber which can be null.  If the above is null, try to fine the line using contains()
	if($null -eq $splitFilePathLineNumber -or $splitFilePathLineNumber.Count -le 0)
	{
		try 
		{
			$i = 0
			foreach($item in $CheckContent)
			{
				if($item.ToLower().Contains("grep"))
				{
					$splitFilePathLineNumber = $i - 1
					break
				}
				$i++
			}
		}
		catch {Write-Verbose "Error getting header information: $($_.Exception.Message)"}
		$headerFileLine = $CheckContent[$splitFilePathLineNumber]
	}
	else 
	{
		 # Header for the rule should start at 0 through the first detected file path subtract 2 since Select-String LineNumber is not 0 based
		$headerLineRange = 0..($splitFilePathLineNumber[0] - 2)
		$headerFileLine = $CheckContent[$headerLineRange]   
        }
	
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
            if ($fileContainsLine -match 'You are accessing a U.S. Government \(USG\) [^"]+(?<=details.)')
            {
                $splitEntries += $fileContainsLine
            }
            else
            {
                $checkContentData = $content.Replace(($fileContainsLine -join "`n"), '{0}')
                foreach ($setting in $fileContainsLine)
                {
                    $splitEntries += $checkContentData -f $setting
                }
            }
        }
    }

    return $splitEntries
}
