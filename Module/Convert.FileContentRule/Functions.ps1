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
        $stigRule
    )

    $fileContentRules = @()
    $checkStrings = $stigRule.rule.Check.('check-content')

    if ( [FileContentRule]::HasMultipleRules( $checkStrings ) )
    {
        $splitFileContentEntries = [FileContentRule]::SplitMultipleRules( $checkStrings )

        [int]$byte = 97
        $id = $stigRule.id
        foreach ($splitFileContentEntry in $splitFileContentEntries)
        {
            $stigRule.id = "$id.$([CHAR][BYTE]$byte)"
            $stigRule.rule.Check.('check-content') = $splitFileContentEntry
            $fileContentRules += New-FileContentRule -StigRule $stigRule
            $byte ++
        }
    }
    else
    {
        $fileContentRules += ( New-FileContentRule -StigRule $stigRule )
    }
    return $fileContentRules
}

<#
    .SYNOPSIS
       Calls the FileContent class to generate a fileContent specfic object.
#>
function New-FileContentRule
{
    [CmdletBinding()]
    [OutputType([FileContentRule])]
    Param
    (
        [parameter(Mandatory = $true)]
        [xml.xmlelement]
        $stigRule
    )

    $fileContentRule = [FileContentRule]::New( $stigRule )
    $fileContentRule.SetKeyName()
    $fileContentRule.SetValue()
    $fileContentRule.SetStigRuleResource()

    if ($fileContentRule.conversionstatus -eq 'pass')
    {
        if ( $fileContentRule.IsDuplicateRule( $global:stigSettings ))
        {
            $fileContentRule.SetDuplicateTitle()
        }
    }
    return $fileContentRule
}
#endregion
