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

    $checkStrings = $StigRule.rule.Check.('check-content')

    if ( [FileContentRule]::HasMultipleRules( $checkStrings ) )
    {
        $splitFileContentEntries = [FileContentRule]::SplitMultipleRules( $checkStrings )
        $fileContentRules = @()
        [int]$byte = 97
        $id = $StigRule.id
        foreach ($splitFileContentEntry in $splitFileContentEntries)
        {
            $StigRule.id = "$id.$([CHAR][BYTE]$byte)"
            $StigRule.rule.Check.('check-content') = $splitFileContentEntry
            $fileContentRules += [FileContentRule]::New( $StigRule )
            $byte ++
        }

        return $fileContentRules
    }
    else
    {
        return [FileContentRule]::New( $StigRule )
    }
}

#endregion
