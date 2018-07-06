#region Header
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\..\Public\Class\Common.Enum.psm1
using module .\..\..\Public\Data\Convert.Data.psm1
# Class module
using module .\..\..\Public\Class\Convert.WebAppPoolRule.psm1
#endregion
#region Main Functions
<#
    .SYNOPSIS
        Accepts the raw stig string data and converts it to a WebAppPoolRule object.

    .PARAMETER StigRule
        The xml Stig rule from the XCCDF.
#>
function ConvertTo-WebAppPoolRule
{
    [CmdletBinding()]
    [OutputType([WebAppPoolRule])]
    Param
    (
        [Parameter(Mandatory = $true)]
        [xml.xmlelement]
        $StigRule
    )

    Write-Verbose "[$($MyInvocation.MyCommand.Name)]"

    $webAppPool = [WebAppPoolRule]::New( $StigRule )

    $webAppPool.SetKeyValuePair()

    if ($webAppPool.IsOrganizationalSetting())
    {
        $webAppPool.SetOrganizationValueTestString()
    }

    if ($webAppPool.conversionstatus -eq 'pass')
    {
        if ( $webAppPool.IsDuplicateRule( $global:stigSettings ))
        {
            $webAppPool.SetDuplicateTitle()
        }
    }

    $webAppPool.SetStigRuleResource()

    return $webAppPool
}
#endregion
