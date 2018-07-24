# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
#region Functions
<#
    .SYNOPSIS
       Calls the ProcessMitigationRule class to generate a Process Mitigation Policy specfic object.
#>
function ConvertTo-ProcessMitigationRule
{
    [CmdletBinding()]
    [OutputType([ProcessMitigationRule])]
    Param
    (
        [parameter(Mandatory = $true)]
        [xml.xmlelement]
        $StigRule
    )

    Write-Verbose "[$($MyInvocation.MyCommand.Name)]"

    $processMitigationRule = [ProcessMitigationRule]::New( $StigRule )
    $processMitigationRule.SetStigRuleResource()
    $processMitigationRule.SetMitigationTargetName()
    $processMitigationRule.SetMitigationToEnable()

    $mitigationTargetList = $processMitigationRule.MitigationTarget

    if ( [ProcessMitigationRule]::HasMultipleRules( $mitigationTargetList ) )
    {
        $firstElement = $true
        [int] $byte = 97
        $tempRule = $processMitigationRule.Clone()
        [string[]] $splitRules = [ProcessMitigationRule]::SplitMultipleRules( $mitigationTargetList )

        foreach ( $mitigationTarget in $splitRules )
        {
            if ( $firstElement )
            {
                $processMitigationRule.MitigationTarget = $mitigationTarget
                $processMitigationRule.id = "$($processMitigationRule.id).$([CHAR][BYTE]$byte)"
                $firstElement = $false
            }
            else
            {
                $newRule = $tempRule.Clone()
                $newRule.mitigationTarget = $mitigationTarget
                $newRule.id = "$($newRule.id).$([CHAR][BYTE]$byte)"
                [void] $global:stigSettings.Add($newRule)
            }
            $byte++
        }
    }

    if ($processMitigationRule.conversionstatus -eq 'pass')
    {
        if ( $processMitigationRule.IsDuplicateRule( $global:stigSettings ))
        {
            $processMitigationRule.SetDuplicateTitle()
        }
    }
    return $processMitigationRule
}
#endregion
