# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

#region Header
#endregion
#region Main Function
<#
    .SYNOPSIS
        Identifies the type of STIG that has been input and selects the proper private function to
        further convert the STIG strings into usable objects.

    .DESCRIPTION
        This function enables the core translation of the raw xccdf file by reading the benchmark
        title property to determine where to send the data for processing.

        When a ruleset match is found, the xccdf data is sent to private functions that are
        dedicated to processing individual STIG setting types, such as registry settings or
        security policy.

        If the function is unable to find a rule set match, an error is returned.

    .PARAMETER Path
        The path to the xccdf file to be processed.

    .PARAMETER IncludeRawString
        This will add the 'Check-Content' from the xcccdf to the output for any additional validation
        or spot checking that may be needed.

    .EXAMPLE
        ConvertFrom-StigXccdf -Path C:\Stig\U_Windows_2012_and_2012_R2_MS_STIG_V2R8_Manual-xccdf.xml

    .OUTPUTS
        Custom objects are created from the STIG base class that are provided in the module

    .NOTES
        This is an ongoing project that should be retested with each iteration of the STIG. This is
        due to the non-standard way, the content is published. Each version of the STIG may require
        a rule to be updated to account for a new string format. All the formatting rules are heavily
        tested, so making changes is a simple task.

    .LINK
        http://iase.disa.mil/stigs/Lists/stigs-masterlist/AllItems.aspx
#>
function ConvertFrom-StigXccdf
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [string]
        $Path,

        [parameter()]
        [switch]
        $IncludeRawString
    )

    # Get the xml data from the file path provided.
    $stigBenchmarkXml = Get-StigXccdfBenchmarkContent -Path $Path

    # Global variable needed to distinguish between the IIS server and site stigs. Server Stig needs xIISLogging resource, Site Stig needs XWebsite
    $global:stigTitle = $stigBenchmarkXml.title

    # Read in the root stig data from the xml additional functions will dig in deeper
    $stigRuleParams = @{
        StigGroups       = $stigBenchmarkXml.Group
        IncludeRawString = $IncludeRawString
    }

    # The benchmark title drives the rest of the function and must exist to continue.
    if ( $null -eq $stigBenchmarkXml.title )
    {
        Write-Error -Message 'The Benchmark title property is null. Unable to determine ruleset target.'
        return
    }

    return Get-StigRuleList @stigRuleParams
}

<#
    .SYNOPSIS
        Splits the XCCDF of the 2016 STIG into the MS and DC files

    .DESCRIPTION
        This function is a pre processor of the raw XCCDF, and only alters the Check content strings
        so that they can be processed like the rest of the STIG settings.

    .PARAMETER Path
        The path to the xccdf file to be processed.

    .PARAMETER Destination
        The folder to output the split file contents

    .EXAMPLE
        Split-StigXccdf -Path C:\Stig\Windows\U_Windows_Server_2016_STIG_V1R2_Manual-xccdf.xml -Destination C:\Dev

    .OUTPUTS
        DC and MS STIG file that is then processed by the ConvertFrom-StigXccdf
#>
function Split-StigXccdf
{
    [CmdletBinding()]
    [OutputType([object])]
    Param
    (
        [parameter(Mandatory = $true)]
        [string]
        $Path,

        [parameter()]
        [string]
        $Destination
    )

    Begin
    {
        $CurrentVerbosePreference = $global:VerbosePreference

        if ($PSBoundParameters.ContainsKey('Verbose'))
        {
            $global:VerbosePreference = 'Continue'
        }
    }
    Process
    {
        # Get the raw xccdf xml to pull additional details from the root node.
        [xml] $msStig = Get-Content -Path $Path
        [xml] $dcStig = $msStig.Clone()

        # Remove DC only settings from the MS xml
        foreach ($group in $msStig.Benchmark.Group)
        {
            if ($group.Rule.check.'check-content' -match "This applies to domain controllers")
            {
                $msStig.Benchmark.RemoveChild($group)
            }
        }

        # Remove DC only setting from the MS xml
        foreach ($group in $dcStig.Benchmark.Group)
        {
            if ($group.Rule.check.'check-content' -match "This applies to member servers")
            {
                $dcStig.Benchmark.RemoveChild($group)
            }
        }

        #region save the split stig file
        $Destination = Resolve-Path -Path $Destination.TrimEnd("\")
        $fileName = $Path | Split-Path -Leaf

        $fileNameLeaf = ($fileName | Select-String -Pattern '(?<=2016_).*$').Matches.Groups[-1].Value.Trim()
        $fileNameParent = ($fileName | Select-String -Pattern '.*(?=STIG)').Matches.Groups[-1].Value.Trim()
        $fileNameRoot = "$fileNameParent{0}_$fileNameLeaf"

        $msStig.Save("$Destination\$fileNameRoot" -f "MS")
        $dcStig.Save("$Destination\$fileNameRoot" -f "DC")
        #endregion
    }
    End
    {
        $global:VerbosePreference = $CurrentVerbosePreference
    }
}
#endregion
#region Private Functions
<#
    .SYNOPSIS
        Get-StigRuleList determines what type of STIG setting is being processed and sends it to a
        specalized function for additional processing.
    .DESCRIPTION
        Get-StigRuleList pre-sorts the STIG rules that is recieves and tries to determine what type
        of object it should create. For example if the check content has the string HKEY, it assumes
        that the setting is a registry object and sends the check to the registry sub functions to
        further break down the string into a registry object.
    .PARAMETER StigGroups
        An array of the child STIG Group elements from the parent Benchmark element in the xccdf.
    .PARAMETER IncludeRawString
        A flag that returns the unaltered Check-Content with the converted object.
    .NOTES
        General notes
#>
function Get-StigRuleList
{
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param
    (
        [parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [psobject]
        $StigGroups,

        [parameter()]
        [switch]
        $IncludeRawString
    )

    begin
    {
        [System.Collections.ArrayList] $global:stigSettings = @()
        [int] $stigGroupCount = @($StigGroups).Count
        [int] $stigProcessedCounter = 1
    }
    process
    {
        foreach ( $stigRule in $StigGroups )
        {
            # Global added so that the stig rule can be referenced later
            $global:stigRuleGlobal = $stigRule
            $informationParameters = @{
                MessageData       = "INFO: [$stigProcessedCounter of $stigGroupCount] $($stigRule.id)"
                InformationAction = 'Continue'
            }

            Write-Information @informationParameters
            $ruleTypes = [STIG]::GetRuleTypeMatchList( $stigRule.rule.Check.('check-content') )
            foreach ( $ruleType in $ruleTypes )
            {
                $rules = & "ConvertTo-$ruleType" -StigRule $stigRule

                foreach ( $rule in $rules )
                {
                    if ( $rule.title -match 'Duplicate' -or $exclusionRuleList.Contains(($rule.id -split '\.')[0]) )
                    {
                        [void] $global:stigSettings.Add( ( [DocumentRule]::ConvertFrom( $rule ) ) )
                    }
                    else
                    {
                        [void] $global:stigSettings.Add( $rule )
                    }
                }
                # Increment the counter to update the console output
                $stigProcessedCounter ++
            }
        }
    }
    end
    {
        $global:stigSettings
    }
}

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
