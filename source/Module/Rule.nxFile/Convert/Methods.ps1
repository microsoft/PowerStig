# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

<#
    .SYNOPSIS
        Retreives the nxFileLineFilePath from the check-content element in the xccdf

    .PARAMETER FixText
        Specifies the check-content element in the xccdf
#>
function Get-nxFileDestinationPath
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
        # Setting up structure to allow for multiple path detections
        $nxFileDestinationPathAggregate = '{0}' -f
            $regularExpression.nxFileDestinationPath
        $null = $CheckContent -match $nxFileDestinationPathAggregate
        switch ($Matches.Keys)
        {
            'filePath'
            {
                return $Matches['filePath']
            }
            default
            {
                Write-Verbose "[$($MyInvocation.MyCommand.Name)] nxFileDestinationPath : Not Found"
                return $null
            }
        }
    }
    catch
    {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] nxFileDestinationPath : Not Found"
        return $null
    }
}

<#
    .SYNOPSIS
        Retreives the nxFileContents from the check-content element in the xccdf

    .PARAMETER FixText
        Specifies the FixText element in the xccdf

    .NOTES
        As of 10/26/2020 this function is only used for the "legal banner" rule.
#>
function Get-nxFileContents
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
        if ($rawString -match 'You are accessing[^"]+(?<=details.)')
        {
            $results = $matches.Values
        }

        return $results
    }
    catch
    {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] nxFileContents : Not Found"
        return $null
    }
}
