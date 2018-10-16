# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
#region Functions
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
    param
    (
        [Parameter(Mandatory = $true)]
        [xml.xmlelement]
        $stigRule
    )

    Write-Verbose "[$($MyInvocation.MyCommand.Name)]"

    $webAppPool = [WebAppPoolRule]::New( $stigRule )

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
