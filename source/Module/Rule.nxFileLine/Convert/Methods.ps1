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
        $FixText
    )

    Write-Verbose "[$($MyInvocation.MyCommand.Name)]"
    try
    {
        $startLineNumber = ($FixText | Select-String -Pattern $regularExpression.nxFileLineContainsLineStart).LineNumber
        $stopLineNumber = $FixText[$startLineNumber..($FixText.Length - 1)] | Select-String -Pattern $regularExpression.nxFileLineContainsLineStop
        if ($null -eq $stopLineNumber)
        {
            $stopLineNumber = $FixText.Length - 1
        }
        else
        {
            $stopLineNumber = $stopLineNumber.LineNumber
        }

        if ($startLineNumber -gt $stopLineNumber)
        {
            return $FixText[$FixText.Length - 1]
        }

        $nxFileLineContains = @()
        foreach ($line in $FixText[$startLineNumber..$stopLineNumber])
        {
            $nxFileLineContains += $line
        }

        return $nxFileLineContains
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
        $FixText
    )

    try
    {
        $null = $FixText -match $regularExpression.nxFileLineFilePath
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
    param
    (
        [Parameter(Mandatory = $true)]
        [string[]]
        $FixText
    )

    try
    {
        $null = $FixText -match $regularExpression.nxFileLineDoesNotContainPattern
        switch ($Matches[''])
        {
            default {return $null}
        }
    }
    catch
    {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] nxFileLineDoesNotContainPattern : Not Found"
        return $null
    }
}
