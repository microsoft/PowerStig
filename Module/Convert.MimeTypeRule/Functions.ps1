# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
#region Functions
<#
    .SYNOPSIS
        Accepts the raw stig string data and converts it to a MimeTypeRule object.

    .PARAMETER StigRule
        The xml Stig rule from the XCCDF.
#>
function ConvertTo-MimeTypeRule
{
    [CmdletBinding()]
    [OutputType([MimeTypeRule])]
    param
    (
        [Parameter(Mandatory = $true)]
        [xml.xmlelement]
        $stigRule
    )

    $mimeTypeRules = @()
    $checkStrings = $stigRule.rule.Check.('check-content')

    if ( [MimeTypeRule]::HasMultipleRules( $checkStrings ) )
    {
        $splitMimeTypeRules = [MimeTypeRule]::SplitMultipleRules( $checkStrings )

        [int]$byte = 97
        $id = $stigRule.id
        foreach ($mimeTypeRule in $splitMimeTypeRules)
        {
            $stigRule.id = "$id.$([CHAR][BYTE]$byte)"
            $stigRule.rule.Check.('check-content') = $mimeTypeRule
            $rule = New-MimeTypeRule -StigRule $stigRule
            $mimeTypeRules += $rule
            $byte ++
        }
    }
    else
    {
        $mimeTypeRules += ( New-MimeTypeRule -StigRule $stigRule )
    }
    return $mimeTypeRules

}
#endregion
#region Support Functions
<#
    .SYNOPSIS
        Creates a new MimeTypeRule

    .PARAMETER StigRule
        The xml Stig rule from the XCCDF.
#>
function New-MimeTypeRule
{
    [CmdletBinding()]
    [OutputType([MimeTypeRule])]
    param
    (
        [Parameter(Mandatory = $true)]
        [xml.xmlelement]
        $stigRule
    )

    Write-Verbose "[$($MyInvocation.MyCommand.Name)]"

    $mimeTypeRule = [MimeTypeRule]::New( $stigRule )

    $mimeTypeRule.SetExtension()

    $mimeTypeRule.SetMimeType()

    $mimeTypeRule.SetEnsure()

    if ($mimeTypeRule.conversionstatus -eq 'pass')
    {
        if ( $mimeTypeRule.IsDuplicateRule( $global:stigSettings ))
        {
            $mimeTypeRule.SetDuplicateTitle()
        }
    }

    $mimeTypeRule.SetStigRuleResource()

    return $mimeTypeRule
}
#endregion
