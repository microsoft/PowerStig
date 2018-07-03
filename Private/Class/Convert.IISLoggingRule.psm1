# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

#region Header
using module ..\..\public\Class\IisLoggingRuleClass.psm1
using module ..\..\public\common\enum.psm1
#endregion
#region Main Functions
<#
    .SYNOPSIS
        Accepts the raw stig string data and converts it to a IisLoggingRule object.

    .PARAMETER StigRule
        The xml Stig rule from the XCCDF.
#>
function ConvertTo-IisLoggingRule
{
    [CmdletBinding()]
    [OutputType([IisLoggingRule])]
    Param
    (
        [Parameter(Mandatory = $true)]
        [xml.xmlelement]
        $StigRule
    )

    Write-Verbose "[$($MyInvocation.MyCommand.Name)]"

    $iisLoggingRule = [IisLoggingRule]::New( $StigRule )

    $iisLoggingRule.SetLogCustomFields()

    $iisLoggingRule.SetLogFlags()

    $iisLoggingRule.SetLogFormat()

    $iisLoggingRule.SetLogPeriod()

    $iisLoggingRule.SetLogTargetW3C()

    $iisLoggingRule.SetStatus()

    $iisLoggingRule.SetStigRuleResource()

    if ($iisLoggingRule.conversionstatus -eq 'pass')
    {
        if ( $iisLoggingRule.IsDuplicateRule( $Global:STIGSettings ))
        {
            $iisLoggingRule.SetDuplicateTitle()
        }
    }

    return $iisLoggingRule
}
#endregion
