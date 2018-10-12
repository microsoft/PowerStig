# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
#region Functions
<#
    .SYNOPSIS
        Creates FileContentRules from the xccdf
#>
function ConvertTo-FileContentRule
{
    [CmdletBinding()]
    [OutputType([FileContentRule])]
    Param
    (
        [Parameter(Mandatory = $true)]
        [xml.xmlelement]
        $StigRule
    )

    $fileContentRules = @()
    $checkStrings = $StigRule.rule.Check.('check-content')

    if ( [FileContentRule]::HasMultipleRules( $checkStrings ) )
    {
        $splitFileContentEntries = [FileContentRule]::SplitMultipleRules( $checkStrings )

        [int]$byte = 97
        $id = $StigRule.id
        foreach ($splitFileContentEntry in $splitFileContentEntries)
        {
            $StigRule.id = "$id.$([CHAR][BYTE]$byte)"
            $StigRule.rule.Check.('check-content') = $splitFileContentEntry
            $fileContentRules += [FileContentRule]::New( $StigRule )
            $byte ++
        }
    }
    else
    {
        $fileContentRules += ( New-FileContentRule -StigRule $StigRule )
    }
    return $fileContentRules
}

#endregion
