# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

<#
    .SYNOPSIS
        Returns the benchmark element from the xccdf xml document.

    .PARAMETER Path
        The literal path to the the zip file that contain the xccdf or the specifc xccdf file.
#>
function Get-StigXccdfBenchmarkContent
{
    [CmdletBinding()]
    [OutputType([xml])]
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

    $xccdfXmlContent.Benchmark
}

<#
    .SYNOPSIS
        Extracts the xccdf file from the zip file provided from the DISA website.

    .PARAMETER Path
        The literal path to the zip file.
#>
function Get-StigContentFromZip
{
    [CmdletBinding()]
    [OutputType([xml])]
    param
    (
        [parameter(Mandatory = $true)]
        [string]
        $Path
    )

    # Create a unique path in the users temp directory to expand the files to.
    $zipDestinationPath = "$((Split-Path -Path $Path -Leaf) -replace '.zip','').$((Get-Date).Ticks)"
    Expand-Archive -LiteralPath $Path -DestinationPath $zipDestinationPath
    # Get the full path to the extracted xccdf file.
    $getChildItem = @{
        Path = $zipDestinationPath
        Filter = "*Manual-xccdf.xml"
        Recurse = $true
    }

    $xccdfPath = (Get-ChildItem @getChildItem).fullName
    # Get the xccdf content before removing the content from disk.
    $xccdfContent = Get-Content -Path $xccdfPath
    # Cleanup to temp folder
    Remove-Item $zipDestinationPath -Recurse -Force

    $xccdfContent
}
