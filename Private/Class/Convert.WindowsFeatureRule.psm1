#region Header
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\..\Public\Class\Common.Enum.psm1
using module .\..\..\Public\Data\Convert.Data.psm1
# Class module
using module .\..\..\Public\Class\Convert.WindowsFeatureRule.psm1
#endregion
#region Main Functions
<#
    .SYNOPSIS
        Uses the WindowsFeatureRule class to parse the STIG item and convert it into a WindowsFeature
        object
#>
function ConvertTo-WindowsFeatureRule
{
	[CmdletBinding()]
	[OutputType( [WindowsFeatureRule] )]
    Param
    (
        [parameter(Mandatory = $true)]
        [xml.xmlelement]
        $StigRule
    )

    Write-Verbose "[$($MyInvocation.MyCommand.Name)]"

    $windowsFeatureRule = [WindowsFeatureRule]::New( $StigRule )

    $windowsFeatureRule.SetFeatureName()

    $windowsFeatureRule.SetFeatureInstallState()

    $windowsFeatureRule.SetStigRuleResource()

    $featureNameList = $windowsFeatureRule.FeatureName

    if ( [WindowsFeatureRule]::HasMultipleRules( $featureNameList ) )
    {
        $firstElement = $true
        [int] $byte = 97
        $tempRule = $windowsFeatureRule.Clone()
        [string[]] $splitRules = [WindowsFeatureRule]::SplitMultipleRules( $featureNameList )

        foreach ( $windowsFeatureName in $splitRules )
        {
            if ( $firstElement )
            {
                $windowsFeatureRule.FeatureName = $windowsFeatureName
                $windowsFeatureRule.id = "$($windowsFeatureRule.id).$([CHAR][BYTE]$byte)"
                $firstElement = $false
            }
            else
            {
                $newRule = $tempRule.Clone()
                $newRule.FeatureName = $windowsFeatureName
                $newRule.id = "$($newRule.id).$([CHAR][BYTE]$byte)"
                [void] $global:stigsettings.Add($newRule)
            }
            $byte++
        }
    }

    if ($windowsFeatureRule.conversionstatus -eq 'pass')
    {
        if ( $windowsFeatureRule.IsDuplicateRule( $global:STIGSettings ))
        {
            $windowsFeatureRule.SetDuplicateTitle()
        }
    }
    return $windowsFeatureRule
}
#endregion Main Functions
