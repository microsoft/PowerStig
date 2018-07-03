# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

#region Header
using module ..\..\public\Class\ProcessMitigationRuleClass.psm1
using module ..\..\public\common\enum.psm1
#endregion
#region Main Functions
<#
    .SYNOPSIS
       Calls the ProcessMitigationRule class to generate an Process Mitigation Policy specfic object.
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
                [void] $global:stigsettings.Add($newRule)
            }
            $byte++
        }
    }

    if ($processMitigationRule.conversionstatus -eq 'pass')
    {
        if ( $processMitigationRule.IsDuplicateRule( $global:STIGSettings ))
        {
            $processMitigationRule.SetDuplicateTitle()
        }
    }
    return $processMitigationRule
}
#endregion
