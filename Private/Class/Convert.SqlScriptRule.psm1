#region Header
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\..\Public\Class\Common.Enum.psm1
using module .\..\..\Public\Data\Convert.Data.psm1
# Class module
using module .\..\..\Public\Class\Convert.SqlScriptRule.psm1
#endregion
#region Main Functions
<#
    .SYNOPSIS
       Creates the registry rule.
#>
function ConvertTo-SqlScriptRule
{
    [CmdletBinding()]
    [OutputType([SqlScriptRule])]
    Param
    (
        [parameter(Mandatory = $true)]
        [xml.xmlelement]
        $StigRule
    )

    Write-Verbose "[$($MyInvocation.MyCommand.Name)]"

    $sqlScriptRule = [SqlScriptRule]::New( $StigRule )

    $ruleType = $sqlScriptRule.GetRuleType( $sqlScriptRule.splitCheckContent )

    $fixText = [SqlScriptRule]::GetFixText( $StigRule )

    $sqlScriptRule.SetStigRuleResource()

    $sqlScriptRule.SetGetScript( $ruleType )

    $sqlScriptRule.SetTestScript( $ruleType )

    $sqlScriptRule.SetSetScript( $ruleType, $fixText )

    if ( $sqlScriptRule.IsDuplicateRule( $global:stigSettings ) )
    {
        $sqlScriptRule.SetDuplicateTitle()
    }

    return $sqlScriptRule
}
#endregion Main Functions
