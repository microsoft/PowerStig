# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

#region Header
using module .\..\..\public\data\data.xml.psm1
#endregion
#region Data
$organizationalSettingRootComment = @'

    The organizational settings file is used to define the local organizations
    preferred setting within an allowed range of the STIG.

    Each setting in this file is linked by STIG ID and the valid range is in an
    associated comment.

'@
#endregion
#region Main Functions
<#
    .SYNOPSIS
        Creates the Organizational settings file that accompanies the converted STIG data.

    .PARAMETER convertedStigObjects
        The Converted Stig Objects to sort through

    .PARAMETER StigVersionNumber
        The version number of the xccdf that is being processed.

    .PARAMETER Destination
        The path to store the output file.

    .NOTES
    General notes
#>
function New-OrganizationalSettingsXmlFile
{
    [CmdletBinding()]
    [OutputType()]
    param
    (
        [parameter(Mandatory = $true)]
        [psobject]
        $ConvertedStigObjects,

        [parameter(Mandatory = $true)]
        [version]
        $StigVersionNumber,

        [parameter(Mandatory = $true)]
        [string]
        $Destination
    )

    $orgSettings = Get-StigObjectsWithOrgSettings -ConvertedStigObjects $ConvertedStigObjects

    $xmlDocument = [System.XML.XMLDocument]::New()

    ##############################   Root object   ###################################
    [System.XML.XMLElement] $xmlRootElement = $xmlDocument.CreateElement(
        $xmlElement.organizationalSettingRoot )

    [void] $xmlDocument.appendChild( $xmlRootElement )
    [void] $xmlRootElement.SetAttribute( $xmlAttribute.stigVersion, $StigVersionNumber )

    $rootComment = $xmlDocument.CreateComment( $organizationalSettingRootComment )
    [void] $xmlDocument.InsertBefore( $rootComment, $xmlRootElement )

    #########################################   Root object   ##########################################
    #########################################    ID object    ##########################################

    foreach ( $orgSetting in $orgSettings)
    {
        [System.XML.XMLElement] $xmlSettingChildElement = $xmlDocument.CreateElement(
            $xmlElement.organizationalSettingChild )

        [void] $xmlRootElement.appendChild( $xmlSettingChildElement )

        $xmlSettingChildElement.SetAttribute( $xmlAttribute.ruleId , $orgSetting.id )

        $xmlSettingChildElement.SetAttribute( $xmlAttribute.organizationalSettingValue , "LOCAL_STIG_SETTING_HERE")

        $settingComment = " Ensure $(($orgSetting.OrganizationValueTestString) -f "'$($orgSetting.Id)'")"

        $rangeNameComment = $xmlDocument.CreateComment($settingComment)
        [void] $xmlRootElement.InsertBefore($rangeNameComment, $xmlSettingChildElement)
    }
    #########################################    ID object    ##########################################

    $xmlDocument.Save( $Destination )
}

<#
    .SYNOPSIS
        Creates a version number from the xccdf benchmark element details.

    .PARAMETER stigDetails
        A reference to the in memory xml document.

    .NOTES
        This function should only be called from the public ConvertTo-DscStigXml function.
#>
function Get-StigVersionNumber
{
    [CmdletBinding()]
    [OutputType([version])]
    param
    (
        [parameter(Mandatory = $true)]
        [xml]
        $stigDetails
    )

    # Extract the revision number from the xccdf
    $revision = ( $stigDetails.Benchmark.'plain-text'.'#text' `
            -split "(Release:)(.*?)(Benchmark)" )[2].trim()

    "$($stigDetails.Benchmark.version).$revision"
}

<#
    .SYNOPSIS
        Filters the lsit of STIG objects and returns anything that requires an organizational desicion.

    .PARAMETER convertedStigObjects
        A reference to the object that contains the converted stig data.

    .NOTES
        This function should only be called from the public ConvertTo-DscStigXml function.
#>
function Get-StigObjectsWithOrgSettings
{
    [CmdletBinding()]
    [OutputType([psobject])]
    param
    (
        [parameter(Mandatory = $true)]
        [psobject]
        $ConvertedStigObjects
    )

    $ConvertedStigObjects |
        Where-Object { $PSitem.OrganizationValueRequired -eq $true}
}

<#
    .SYNOPSIS
        Gets the target folder name in the composite based on the xccdf title.

    .PARAMETER Path
        A reference to the xccdf that was converted.

    .NOTES
        This function should only be called from the public ConvertTo-DscStigXml function.
#>
function Get-CompositeTargetFolder
{
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        [parameter(Mandatory = $true)]
        [string]
        $Path
    )

    [xml] $xccdf = Get-Content -Path $path -Encoding UTF8

    Switch ($xccdf.Benchmark.title)
    {
        {$PSItem -match '(?=.*Windows)(?=.*Domain(\s*)Controller)'}
        {return 'WindowsServerDC'}
        {$PSItem -match '(?=.*Windows)(?=.*Member(\s*)Server)'}
        {return 'WindowsServerMS'}
    }

}

<#
    .SYNOPSIS
        Filters the lsit of STIG objects and returns anything that requires an organizational desicion.

    .PARAMETER Path
        A reference to the object that contains the converted stig data.

    .PARAMETER Destination
        A reference to the object that contains the converted stig data.

    .NOTES
        This function should only be called from the public ConvertTo-DscStigXml function.
#>
function Get-OutputFileRoot
{
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        [parameter(Mandatory = $true)]
        [string]
        $Path,

        [parameter()]
        [string]
        $Destination
    )

    $outFileNameRoot = ( Split-Path $Path -Leaf ) -replace '_Manual-xccdf.xml', ''

    $CompositeStigDscIsFound = Get-Module -ListAvailable CompositeStigDsc -Verbose:$false

    if ($CompositeStigDscIsFound -and -not $Destination)
    {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Adding file to Composite Resource"
        $CompositeTargetFolder = Get-CompositeTargetFolder -Path $Path
        $OutPath = "$($CompositeStigDscIsFound.ModuleBase)\DscResources\$CompositeTargetFolder\stigData"
    }
    elseif ($Destination)
    {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Adding file to $Destination"
        $OutPath = $Destination
    }
    else
    {
        $sourceFilePath = ( Split-Path $Path -Parent )
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Adding file to local directory $sourceFilePath"
        $OutPath = "$sourceFilePath"
    }

    if (Test-Path $OutPath)
    {
        "$OutPath\$outFileNameRoot"
    }
    else
    {
        throw "$OutPath was not found"
    }
}
#endregion
