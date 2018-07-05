# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

#region Main Functions
<#
    .SYNOPSIS
        Returns the benchmark element from the xccdf xml document.

    .PARAMETER Path
        The literal path to the the zip file that contain the xccdf or the specifc xccdf file.

    .NOTES
        General notes
#>
function Get-StigXccdfBenchmarkContent
{
    [cmdletbinding()]
    [outputtype([xml])]
    param
    (
        [parameter(Mandatory = $true)]
        [string]
        $Path
    )

    if (-not (Test-Path -Path $Path))
    {
        Throw "The file $Path was not found"
    }

    if ($Path -like "*.zip")
    {
        [xml] $xccdfXmlContent = Get-StigContentFromZip -Path $Path
    }
    else
    {
        [xml] $xccdfXmlContent = Get-Content -Path $Path -Encoding UTF8
    }

    if (Test-ValidXccdf -xccdfXmlContent $xccdfXmlContent )
    {
        $xccdfXmlContent.Benchmark
    }
    else
    {
        Throw "$Path does not contain valid xccdf xml."
    }
}

<#
    .SYNOPSIS
        Extracts the xccdf file from the zip file provided from the DISA website.

    .PARAMETER Path
        The literal path to the zip file.

    .NOTES
        General notes
#>
function Get-StigContentFromZip
{
    [cmdletbinding()]
    [outputtype([xml])]
    param
    (
        [parameter(Mandatory = $true)]
        [string]
        $Path
    )

    # Create a unique path in the users temp directory to expand the files to.
    $zipDestinationPath = "$((Split-Path -Path $Path -Leaf) -replace '.zip','').$((Get-Date).Ticks)"
    Expand-Archive -LiteralPath $filePath -DestinationPath $zipDestinationPath
    # Get the full path to teh extracted xccdf file.
    $xccdfPath = (
        Get-ChildItem -Path $zipDestinationPath -Filter "*Manual-xccdf.xml" -Recurse -Verbose
    ).fullName
    # Get the xccdf content before removing the content from disk.
    $xccdfContent = Get-Content -Path $xccdfPath
    # Cleanup to temp folder
    Remove-Item $zipDestinationPath -Recurse -Force

    $xccdfContent
}

<#
    .SYNOPSIS
        Validates that the specific child elements the conversion process needs are avaialbe.

    .PARAMETER xccdfXmlContent
        Parameter description

    .NOTES
        General notes
#>
function Test-ValidXccdf
{
    [cmdletbinding()]
    [outputtype([bool])]
    param
    (
        [parameter(Mandatory = $true)]
        [xml]
        $xccdfXmlContent
    )

    $isValidXccdf = $true

    if ($null -eq $xccdfXmlContent.Benchmark)
    {
        return $false
    }

    switch($xccdfXmlContent.Benchmark)
    {
        {$null -eq $PSItem.title}{$isValidXccdf = $false}
        {$null -eq $PSItem.version}{$isValidXccdf = $false}
        {$null -eq $PSItem.Group}{$isValidXccdf = $false}
    }

    $isValidXccdf
}
#endregion
