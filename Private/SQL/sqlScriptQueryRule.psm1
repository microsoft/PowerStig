# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

#region Header
using module ..\..\public\Class\SqlScriptQueryRuleClass.psm1
using module ..\..\public\common\enum.psm1
#endregion Header
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
