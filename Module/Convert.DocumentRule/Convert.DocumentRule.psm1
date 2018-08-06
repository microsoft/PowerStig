# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\Common\Common.psm1
using module .\..\Convert.Stig\Convert.Stig.psm1

$exclude = @($MyInvocation.MyCommand.Name,'Template.*.txt')
$supportFileList = Get-ChildItem -Path $PSScriptRoot -Exclude $exclude
Foreach ($supportFile in $supportFileList)
{
    Write-Verbose "Loading $($supportFile.FullName)"
    . $supportFile.FullName
}
# Header

<#
    .SYNOPSIS

    .DESCRIPTION

    .EXAMPLE
#>
Class DocumentRule : STIG
{
    <#
        .SYNOPSIS
            Default constructor

        .DESCRIPTION
            Converts a xccdf stig rule element into a {0}

        .PARAMETER StigRule
            The STIG rule to convert
    #>
    DocumentRule ( [xml.xmlelement] $StigRule )
    {
        $this.InvokeClass( $StigRule )
    }

    <#
        .SYNOPSIS
            Default constructor

        .DESCRIPTION
            Converts a xccdf stig rule element into a {0}

        .PARAMETER Id
            The STIG ID

        .PARAMETER Severity
            The STIG Severity

        .PARAMETER Title
            The STIG Title

        .PARAMETER RawString
            The chcek-content element of the STIG xccdf
    #>
    DocumentRule ( [string] $Id, [severity] $Severity, [string] $Title, [string] $RawString )
    {
        $this.Id = $Id
        $this.severity = $Severity
        $this.title = $Title
        $this.rawString = $RawString
        $this.SetStigRuleResource()
    }

    <#
        .SYNOPSIS

        .DESCRIPTION

        .PARAMETER RuleToConvert
            A STIG rule that has already been parsed.

        .EXAMPLE
    #>
    static [DocumentRule] ConvertFrom ( [object] $RuleToConvert )
    {
        return [DocumentRule]::New($RuleToConvert.Id, $RuleToConvert.severity,
            $RuleToConvert.title, $RuleToConvert.rawString)
    }
}
