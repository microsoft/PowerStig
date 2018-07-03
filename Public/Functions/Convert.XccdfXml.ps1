# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

#region Header
using module ..\..\private\Main.psm1
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

    return Get-StigRules @stigRuleParams
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
        $CurrentVerbosePreference = $Global:VerbosePreference

        if ($PSBoundParameters.ContainsKey('Verbose'))
        {
            $Global:VerbosePreference = 'Continue'
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
        $Destination = $Destination.TrimEnd("\")
        $FilePathRoot = "$($msStig.Benchmark.id)_{0}.xml"

        $msStig.Save("$Destination\$FilePathRoot" -f "MS")
        $dcStig.Save("$Destination\$FilePathRoot" -f "DC")
        #endregion
    }
    End
    {
        $Global:VerbosePreference = $CurrentVerbosePreference
    }
}
#endregion
