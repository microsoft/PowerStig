# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

#region Header
using module ..\..\public\Class\WebConfigurationPropertyClass.psm1
using module ..\..\public\common\enum.psm1
#endregion
#region Main Functions
<#
    .SYNOPSIS
        Accepts the raw stig string data and converts it to a WebConfigurationPropertyRule object.

    .PARAMETER StigRule
        The xml Stig rule from the XCCDF.
#>
function ConvertTo-WebConfigurationPropertyRule
{
    [CmdletBinding()]
    [OutputType([WebConfigurationPropertyRule])]
    Param
    (
        [Parameter(Mandatory = $true)]
        [xml.xmlelement]
        $StigRule
    )

    Write-Verbose "[$($MyInvocation.MyCommand.Name)]"

    $webConfigurationPropertyRules = @()
    $checkStrings = $StigRule.rule.Check.('check-content')

    if ( [WebConfigurationPropertyRule]::HasMultipleRules( $checkStrings ) )
    {
        $splitWebConfigurationPropertyRules = [WebConfigurationPropertyRule]::SplitMultipleRules( $checkStrings )

        [int]$byte = 97
        $id = $StigRule.id
        foreach ($webConfigurationPropertyRule in $splitWebConfigurationPropertyRules)
        {
            $StigRule.id = "$id.$([CHAR][BYTE]$byte)"
            $StigRule.rule.Check.('check-content') = $webConfigurationPropertyRule
            $rule = New-WebConfigurationPropertyRule -StigRule $StigRule
            $webConfigurationPropertyRules += $rule
            $byte ++
        }
    }
    else
    {
        $webConfigurationPropertyRules += ( New-WebConfigurationPropertyRule -StigRule $StigRule )
    }
    return $webConfigurationPropertyRules

}
#endregion
#region Support Functions
<#
.SYNOPSIS
    Creates a new WebConfigurationPropertyRule

.PARAMETER StigRule
        The xml Stig rule from the XCCDF.

#>
function New-WebConfigurationPropertyRule
{
    [CmdletBinding()]
    [OutputType([WebConfigurationPropertyRule])]
    Param
    (
        [Parameter(Mandatory = $true)]
        [xml.xmlelement]
        $StigRule
    )

    Write-Verbose "[$($MyInvocation.MyCommand.Name)]"

    $webConfigurationProperty = [WebConfigurationPropertyRule]::New( $StigRule )

    $webConfigurationProperty.SetConfigSection()

    $webConfigurationProperty.SetKeyValuePair()

    if ($webConfigurationProperty.IsOrganizationalSetting())
    {
        $webConfigurationProperty.SetOrganizationValueTestString()
    }

    if ($webConfigurationProperty.conversionstatus -eq 'pass')
    {
        if ( $webConfigurationProperty.IsDuplicateRule( $Global:STIGSettings ))
        {
            $webConfigurationProperty.SetDuplicateTitle()
        }
    }

    $webConfigurationProperty.SetStigRuleResource()

    return $webConfigurationProperty

}
#endregion
