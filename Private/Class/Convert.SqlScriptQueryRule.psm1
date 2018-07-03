#region Header
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\..\Public\Class\Common.Enum.psm1
using module .\..\..\Public\Data\Convert.Data.psm1
# Class module
using module .\..\..\Public\Class\Convert.SqlScriptQueryRule.psm1
#endregion
#region Main Functions
<#
    .SYNOPSIS
       Creates the registry rule.
#>
function ConvertTo-SqlScriptQueryRule
{
    [CmdletBinding()]
    [OutputType([SqlScriptQueryRule])]
    Param
    (
        [parameter(Mandatory = $true)]
        [xml.xmlelement]
        $StigRule
    )

    Write-Verbose "[$($MyInvocation.MyCommand.Name)]"

    $sqlScriptQueryRule = [SqlScriptQueryRule]::New( $StigRule )

    $ruleType = $sqlScriptQueryRule.GetRuleType( $sqlScriptQueryRule.splitCheckContent )

    $fixText = [SqlScriptQueryRule]::GetFixText( $StigRule )

    $sqlScriptQueryRule.SetStigRuleResource()

    $sqlScriptQueryRule.SetGetScript( $ruleType )

    $sqlScriptQueryRule.SetTestScript( $ruleType )

    $sqlScriptQueryRule.SetSetScript( $ruleType, $fixText )

    if ( $sqlScriptQueryRule.IsDuplicateRule( $Global:STIGSettings ) )
    {
        $sqlScriptQueryRule.SetDuplicateTitle()
    }

    return $sqlScriptQueryRule
}
#endregion Main Functions
