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
        $StigRule
    )

    $checkStrings = $StigRule.rule.Check.('check-content')

    if ( [MimeTypeRule]::HasMultipleRules( $checkStrings ) )
    {
        $splitMimeTypeRules = [MimeTypeRule]::SplitMultipleRules( $checkStrings )
        $mimeTypeRules = @()
        [int]$byte = 97
        $id = $StigRule.id
        foreach ($mimeTypeRule in $splitMimeTypeRules)
        {
            $StigRule.id = "$id.$([CHAR][BYTE]$byte)"
            $StigRule.rule.Check.('check-content') = $mimeTypeRule
            $mimeTypeRules += [MimeTypeRule]::New( $StigRule )
            $byte ++
        }
        return $mimeTypeRules
    }
    else
    {
        return [MimeTypeRule]::New( $StigRule )
    }
}
#endregion
