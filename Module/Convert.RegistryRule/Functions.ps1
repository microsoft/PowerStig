# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
#region Main Functions
<#
 The registry is a major target for the STIG and has quite a few twists and turns when it comes to
 parsing. This overview is to help you visualize the code flow before digging into individual
 functions.

 private\windows\registryRule.ps1:ConvertTo-RegistryRule
    Instantiates the RegistryRule object and populates it properties.

    private\windows\registryRule.ps1:Get-RegistryKey
        Gets or builds the registry key path from the string data

        private\windows\registryRule.ps1:Get-RegistryHiveFromWindowsStig
        private\windows\registryRule.ps1:Get-RegistryPathFromWindowsStig

    private\windows\registryRule.ps1:et-RegistryValueType

    private\windows\registryRule.ps1:Get-RegistryValueName

    private\windows\registryRule.ps1:Get-RegistryValueData

        private\windows\registryRule.ps1:Test-RegistryValueDataContainsRange
            Determines if base string data contains a valid range

        private\common\main.ps1:Get-RegistryValueDataRangeTestString
            Converts the base string data into a comparison test
#>

<#
    .SYNOPSIS
        Accepts the raw stig string data and converts it to a registry object.

    .DESCRIPTION
        The registry data is represented in several different ways in different STIG files. While the
        xccdf is defined by a schema, the check-content data is a free form multiline string. This
        function attempts to extract the individual components of the registry entry and return an
        object that programmatically represents a registry entry.

    .PARAMETER StigRule
        The xml Stig rule from the XCCDF.

    .NOTES
        General notes
#>
function ConvertTo-RegistryRule
{
    [CmdletBinding()]
    [OutputType([RegistryRule[]])]
    Param
    (
        [parameter(Mandatory = $true)]
        [xml.xmlelement]
        $StigRule
    )

    Write-Verbose "[$($MyInvocation.MyCommand.Name)]"

    <#
        There are several registry rules that define multiple registry values in a single rule.
        These need to be split into individual registry objects for DSC to process. Detect them
        before creating the Registry Rule class so that we can append the ID and title with a
        character to identify it as a child object of a specific STIG setting.
    #>
    $RegistryRules = @()
    $checkStrings = $StigRule.rule.Check.('check-content')

    if ( [RegistryRule]::HasMultipleRules( $checkStrings ) )
    {
        $splitRegistryEntries = [RegistryRule]::SplitMultipleRules( $checkStrings )

        [int]$byte = 97
        $id = $StigRule.id
        foreach ($splitRegistryEntry in $splitRegistryEntries)
        {
            $StigRule.id = "$id.$([CHAR][BYTE]$byte)"
            $StigRule.rule.Check.('check-content') = $splitRegistryEntry
            $Rule = New-RegistryRule -StigRule $StigRule
            $RegistryRules += $Rule
            $byte ++
        }
    }
    else
    {
        $RegistryRules += ( New-RegistryRule -StigRule $StigRule )
    }
    return $RegistryRules
}
#endregion
#region Support Function
<#
    .SYNOPSIS
       Creates the registry rule.
#>
function New-RegistryRule
{
    [CmdletBinding()]
    [OutputType([RegistryRule])]
    Param
    (
        [parameter(Mandatory = $true)]
        [xml.xmlelement]
        $StigRule
    )

    Write-Verbose "[$($MyInvocation.MyCommand.Name)]"
    $registryRule = [RegistryRule]::New( $StigRule )

    $registryRule.SetKey()

    $registryRule.SetValueName( )

    $registryRule.SetValueType( )

    $registryRule.SetStigRuleResource()

    #First check if there are rules that require hard coded organization value test strings
    if ($registryRule.IsHardCodedOrganizationValueTestString())
    {
        $OrganizationValueTestString = $registryRule.GetHardCodedOrganizationValueTestString()
        $registryRule.set_OrganizationValueTestString($OrganizationValueTestString)

        $registryRule.SetOrganizationValueRequired()
    }
    else
    {
        # Get the trimmed version of the value data line.
        [string] $registryValueData = $registryRule.GetValueData( )

        # If a range is found on the value line, it needs further processing.
        if ($registryRule.TestValueDataStringForRange($registryValueData))
        {
            # Set the OrganizationValueRequired flag to true so that a org level setting will be required.
            $registryRule.SetOrganizationValueRequired()

            # Try to extract a test string from the range text.
            $OrganizationValueTestString = $registryRule.GetOrganizationValueTestString($registryValueData)

            # If a test string was returned, add it.
            if ($null -ne $OrganizationValueTestString)
            {
                $registryRule.set_OrganizationValueTestString($OrganizationValueTestString)
            }
        }
        else
        {
            if ($registryRule.IsHardCoded( ))
            {
                $registryValueData = $registryRule.GetHardCodedString( )
            }
            elseif ($registryRule.IsDataBlank($registryValueData))
            {
                $registryRule.SetIsNullOrEmpty()
                $registryValueData = ''
            }
            elseif ($registryRule.IsDataEnabledOrDisabled($registryValueData))
            {
                $registryValueData = $registryRule.GetValidEnabledOrDisabled(
                    $registryRule.ValueType, $registryValueData
                )
            }
            elseif ($registryRule.IsDataHexCode($registryValueData))
            {
                $registryValueData = $registryRule.GetIntegerFromHex($registryValueData)
            }
            elseif ($registryRule.IsDataInteger($registryValueData))
            {
                $registryValueData = $registryRule.GetNumberFromString($registryValueData)
            }
            elseif ($registryRule.ValueType -eq 'MultiString')
            {
                if ($registryValueData -match "see below")
                {
                    $registryValueData = $registryRule.GetMultiValueRegistryStringData($checkStrings)
                }
                else
                {
                    $registryValueData = $registryRule.FormatMultiStringRegistryData($registryValueData)
                }
            }
            $registryRule.Set_ValueData($registryValueData)
        }
    }
    return $registryRule
}
#endregion
