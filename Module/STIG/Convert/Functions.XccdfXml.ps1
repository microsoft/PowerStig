# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
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

    .PARAMETER RuleIdFilter
        Filters the list rules that are converted to simplify debugging the conversion process.

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
        [Parameter(Mandatory = $true)]
        [string]
        $Path,

        [Parameter()]
        [string[]]
        $RuleIdFilter
    )

    # Get the xml data from the file path provided.
    $stigBenchmarkXml = Get-StigXccdfBenchmarkContent -Path $path

    # Global variable needed to distinguish between the IIS server and site stigs. Server Stig needs xIISLogging resource, Site Stig needs XWebsite
    $global:stigTitle = $stigBenchmarkXml.title

    # Global variable needed to set and get specific logic needed for filtering and parsing FileContentRules
    switch ($true)
    {
        {$global:stigXccdfName -and -join ((Split-Path -Path $path -Leaf).Split('_') | Select-Object -Index (1, 2)) -eq ''}
        {
            break;
        }
        {!$global:stigXccdfName -or $global:stigXccdfName -ne -join ((Split-Path -Path $path -Leaf).Split('_') | Select-Object -Index (1, 2))}
        {
            $global:stigXccdfName = -join ((Split-Path -Path $path -Leaf).Split('_') | Select-Object -Index (1, 2))
            break;
        }
    }
    # Read in the root stig data from the xml additional functions will dig in deeper
    $stigRuleParams = @{
        StigGroupListChangeLog = Get-RuleChangeLog -Path $Path
    }

    if ($RuleIdFilter)
    {
        $stigRuleParams.StigGroupList = $stigBenchmarkXml.Group | Where-Object {$RuleIdFilter -contains $PSItem.Id}
    }
    else
    {
        $stigRuleParams.StigGroupList = $stigBenchmarkXml.Group
    }

    # The benchmark title drives the rest of the function and must exist to continue.
    if ( $null -eq $stigBenchmarkXml.title )
    {
        Write-Error -Message 'The Benchmark title property is null. Unable to determine ruleset target.'
        return
    }

    Get-RegistryRuleExpressions -Path $Path -StigBenchmarkXml $stigBenchmarkXml

    return Get-StigRuleList @stigRuleParams
}

<#
    .SYNOPSIS
        Loads the regular expressions files

    .DESCRIPTION
        This function loads the regular expression sets to process registry rules in the xccdf file.

    .PARAMETER Path
        The path to the xccdf file to be processed.

    .PARAMETER StigBenchmarkXml
        The xml for the xccdf file to be processed.
#>
function Get-RegistryRuleExpressions
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $Path,

        [Parameter(Mandatory = $true)]
        [object]
        $StigBenchmarkXml
    )

    Begin
    {
        # Use $stigBenchmarkXml.id to determine the stig file
        $benchmarkId = Split-BenchmarkId $stigBenchmarkXml.id
        if ([string]::IsNullOrEmpty($benchmarkId.TechnologyRole))
        {
            $benchmarkId.TechnologyRole = $stigBenchmarkXml.id
        }

        # Handles testing and production
        $xccdfFileName = Split-Path $Path -Leaf
        $spInclude = @('Data.Core.ps1')
        if ($xccdfFileName -eq 'TextData.xml')
        {
            # Query TechnologyRole and map to file
            $officeApps = @('Outlook', 'Excel', 'PowerPoint', 'Word')
            $spExclude = @($MyInvocation.MyCommand.Name, 'Template.*.txt', 'Data.ps1', 'Functions.*.ps1', 'Methods.ps1')

            switch ($benchmarkId.TechnologyRole)
            {
                { $null -ne ($officeApps | Where-Object { $benchmarkId.TechnologyRole -match $_ }) }
                {
                    $spInclude += "Data.Office.ps1"
                }
            }
        }
        else
        {
            # Query directory of xccdf file
            $spResult = Split-Path (Split-Path $Path -Parent) -Leaf
            if ($spResult)
            {
                $spInclude += "Data." + $spResult + ".ps1"
            }
        }
    }

    Process
    {
        # Load specific and core expression sets
        $childItemParams = @{
            Path = "$PSScriptRoot\..\..\Rule\Convert"
            Exclude = $spExclude
            Include = $spInclude
            Recurse = $true
        }

        $spSupportFileList = Get-ChildItem @childItemParams | Sort-Object -Descending
        Clear-Variable SingleLine* -Scope Global
        foreach ($supportFile in $spSupportFileList)
        {
            Write-Verbose "Loading $($supportFile.FullName)"
            . $supportFile.FullName
        }
    }
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
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $Path,

        [Parameter()]
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
        [xml] $msStig = Get-Content -Path $path
        [xml] $dcStig = $msStig.Clone()

        # Update the benchmark ID to reflect the STIG content
        $dcStig.Benchmark.id = $msStig.Benchmark.id -replace '_STIG', '_DC_STIG'
        $msStig.Benchmark.id = $msStig.Benchmark.id -replace '_STIG', '_MS_STIG'

        # Remove DC and Core settings from the MS xml
        Write-Information -MessageData "Removing Domain Controller and Core settings from Member Server STIG"
        foreach ($group in $msStig.Benchmark.Group)
        {
            # Remove DC only settings from the MS xml
            if ($group.Rule.check.'check-content' -match "This applies to domain controllers")
            {
                [void] $msStig.Benchmark.RemoveChild($group)
                Write-Information -MessageData "Removing $($group.id)"
                # Continue is used to bypass server core installation check
                continue
            }

            # Remove Core only settings from MS XML
            if ($group.Rule.check.'check-content' -match "For server core installations,")
            {
                [void] $msStig.Benchmark.RemoveChild($group)
                $group.Rule.check.'check-content' = $group.Rule.check.'check-content' -replace "(?=For server core installations,)(?s)(.*$)"
                [void] $msStig.Benchmark.AppendChild($group)
            }
        }

        # Remove Core and MS only settings from the DC xml
        Write-Information -MessageData "Removing Member Server settings from Domain Controller STIG"
        foreach ($group in $dcStig.Benchmark.Group)
        {
            # Remove MS only settings from DC XML
            if ($group.Rule.check.'check-content' -match "This applies to member servers")
            {
                [void] $dcStig.Benchmark.RemoveChild($group)
                Write-Information -MessageData "Removing $($group.id)"
                # Continue is used to bypass server core installation check
                continue
            }

            # Remove Core only settings from DC XML
            if ($group.Rule.check.'check-content' -match "For server core installations,")
            {
                [void] $dcStig.Benchmark.RemoveChild($group)
                $group.Rule.check.'check-content' = $group.Rule.check.'check-content' -replace "(?=For server core installations,)(?s)(.*$)"
                [void] $dcStig.Benchmark.AppendChild($group)
            }
        }

        if ([string]::IsNullOrEmpty($Destination))
        {
            $Destination = Split-Path -Path $path -Parent
        }
        else
        {
            $Destination = $Destination.TrimEnd("\")
        }

        $FilePath = "$Destination\$(Split-Path -Path $path -Leaf)"

        $msStig.Save(($FilePath -replace '2016_STIG', '2016_MS_STIG'))
        $dcStig.Save(($FilePath -replace '2016_STIG', '2016_DC_STIG'))
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
    .PARAMETER StigGroupList
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
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [psobject]
        $StigGroupList,

        [Parameter()]
        [hashtable]
        $StigGroupListChangeLog
    )

    begin
    {
        [System.Collections.ArrayList] $global:stigSettings = @()
        [int] $stigGroupCount = @($StigGroupList).Count
        [int] $stigProcessedCounter = 1

        # Global added so that the stig rule can be referenced later
        if (-not $exclusionRuleList)
        {
            $exclusionFile = Resolve-Path -Path $PSScriptRoot\..\Common\Data.ps1
            . $exclusionFile
        }

    }
    process
    {
        foreach ($stigRule in $StigGroupList)
        {
            # This is to address STIG Rule V-18395 that has multiple rules that are exactly the same under that rule ID.
            if ($stigRule.Rule.Count -gt 1)
            {
                [void]$stigRule.RemoveChild($stigRule.Rule[0])
            }

            # Global added so that the stig rule can be referenced later
            $global:stigRuleGlobal = $stigRule

            Write-Verbose -Message "[$stigProcessedCounter of $stigGroupCount] $($stigRule.id)"

            foreach ($correction in $StigGroupListChangeLog[$stigRule.Id])
            {
                # If the logfile contains a single * as the OldText, treat it as replacing everything with the newText value
                if ($correction.OldText -eq '*')
                {
                    # Resetting OldText '' to the original check-content so the processed xml includes original check-content
                    $correction.OldText = $stigRule.rule.Check.('check-content')
                    $stigRule.rule.Check.('check-content') = $correction.newText
                }
                else
                {
                    $stigRule.rule.Check.('check-content') = $stigRule.rule.Check.('check-content').Replace($correction.oldText, $correction.newText)
                }
            }
            $rules = [ConvertFactory]::Rule($stigRule)

            foreach ($rule in $rules)
            {
                <#
                    At this point the original rule could be split into multiple
                    rules and we would not be sure what original text went where.
                    So we simply unwind the changes we made earlier so that any
                    new text we added is removed by reversing the regex match.
                #>

                # Trim the unique char from split rules if they exist
                foreach ($correction in $StigGroupListChangeLog[($rule.Id -split '\.')[0]])
                {
                    if ($correction.newText -match "HardCodedRule\(\w*Rule\)")
                    {
                        $rule.RawString = $correction.oldText
                    }
                    else
                    {
                        $rule.RawString = $rule.RawString.Replace($correction.newText, $correction.oldText)
                    }
                }

                if ($rule.title -match 'Duplicate' -or $exclusionRuleList.Contains(($rule.id -split '\.')[0]))
                {
                    [void] $global:stigSettings.Add(([DocumentRuleConvert]::ConvertFrom($rule)))
                }
                else
                {
                    [void] $global:stigSettings.Add($rule)
                }
            }
            $stigProcessedCounter ++
        }
    }
    end
    {
        $global:stigSettings
    }
}

#endregion

<#
    .SYNOPSIS
        Looks up the change log for a given xccdf file and loads the changes
#>
function Get-RuleChangeLog
{
    [CmdletBinding()]
    [OutputType([hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $Path
    )

    $path = $Path -replace '\.xml', '.log'

    try
    {
        $updateLog = Get-Content -Path $path -Encoding UTF8 -Raw -ErrorAction Stop
    }
    catch
    {
        Write-Warning "$path not found. Please create it if needed."
        return @{}
    }

    # regex matches is used to capture the log content directly to the changes variable
    $changeList = [regex]::Matches(
        $updateLog, '(?<id>V-\d+)(?:::)(?<oldText>.+)(?:::)(?<newText>.+)'
    )

    # The function returns a hastable
    $updateList = @{}
    foreach ($change in $changeList)
    {
        $id = $change.Groups.Item('id').value
        $oldText = $change.Groups.Item('oldText').value
        # The trim removes any potential CRLF entries that will show up in a regex escape sequence.
        # The replace replaces `r`n with an actual new line. This is useful if you need to add data on a separate line.
        $newText = $change.Groups.Item('newText').value.Trim().Replace('`r`n',[Environment]::NewLine)

        $changeObject = [pscustomobject] @{
            OldText = $oldText
            NewText = $newText
        }

        <#
           Some rule have multiple changes that need to be made, so if a rule already
           has a change, then add the next change to the value (array)
        #>
        if ($updateList.ContainsKey($id))
        {
            $null = $updateList[$id] += $changeObject
        }
        else
        {
            $null = $updateList.Add($id, @($changeObject))
        }
    }

    $updateList
}

