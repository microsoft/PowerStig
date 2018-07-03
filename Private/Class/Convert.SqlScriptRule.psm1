# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

#region Header
using module ..\..\public\Class\SqlScriptRuleClass.psm1
using module ..\..\public\common\enum.psm1
#endregion Header
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

    if ( $sqlScriptRule.IsDuplicateRule( $Global:STIGSettings ) )
    {
        $sqlScriptRule.SetDuplicateTitle()
    }

    return $sqlScriptRule
}
#endregion Main Functions
