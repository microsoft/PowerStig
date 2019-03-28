# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\Common\Common.psm1
using module .\..\Rule\Rule.psm1
#header

<#
    .SYNOPSIS
        An Document Rule object
    .DESCRIPTION
        The DocumentRule class is used to maange the Document Settings.

#>
Class DocumentRule : Rule
{
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
    DocumentRule ([string] $Id, [severity] $Severity, [string] $Title, [string] $RawString)
    {
        $this.Id = $Id
        $this.severity = $Severity
        $this.title = $Title
        $this.rawString = $RawString
        $this.DscResource = 'None'
    }

    DocumentRule () {}

    DocumentRule ([xml.xmlelement] $Rule, [bool] $Convert) : Base ($Rule, $Convert) {}

    DocumentRule ([xml.xmlelement] $Rule) : Base ($Rule) {}

    [PSObject] GetExceptionHelp()
    {
        return @{
            Value = "15"
            Notes = $null
        }
    }
}
