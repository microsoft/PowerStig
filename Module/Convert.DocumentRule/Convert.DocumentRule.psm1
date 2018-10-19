# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\Common\Common.psm1
using module .\..\Rule\Rule.psm1

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
        Convert the contents of an xccdf check-content element into a document object
    .DESCRIPTION
        The DocumentRule class is used to extract the documentation requirements
        from the check-content of the xccdf. Once a STIG rule is identified as a
        document rule, it is passed to the DocumentRule class for parsing
        and validation.
#>
Class DocumentRule : Rule
{
    <#
        .SYNOPSIS
            Default constructor
        .DESCRIPTION
            Converts a xccdf stig rule element into a DocumentRule
        .PARAMETER StigRule
            The STIG rule to convert
    #>
    DocumentRule ( [xml.xmlelement] $StigRule )
    {
        $this.InvokeClass( $StigRule )
        $this.SetDscResource()
    }

    <#
        .SYNOPSIS
            Constructor that fully populates the required properties
        .DESCRIPTION
            Constructor that fully populates the required properties
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
        $this.SetDscResource()
    }

    <#
        .SYNOPSIS
            Converts an existing rule into a document rule
        .DESCRIPTION
            Provides a way to convert stig rules that have already been parsed
            into a document rule type. There are several instances where a STIG
            rule needs to be documented if configure a certain way.
        .PARAMETER RuleToConvert
            A STIG rule that has already been parsed.
    #>
    static [DocumentRule] ConvertFrom ( [object] $RuleToConvert )
    {
        return [DocumentRule]::New($RuleToConvert.Id, $RuleToConvert.severity,
            $RuleToConvert.title, $RuleToConvert.rawString)
    }

    hidden [void] SetDscResource ()
    {
        $this.DscResource = 'None'
    }
}
