# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
#region Functions
<#
    .SYNOPSIS
       Creates the registry rule.
#>
function ConvertTo-SqlScriptQueryRule
{
    [CmdletBinding()]
    [OutputType([SqlScriptQueryRule])]
    param
    (
        [Parameter(Mandatory = $true)]
        [xml.xmlelement]
        $StigRule
    )

    Write-Verbose "[$($MyInvocation.MyCommand.Name)]"

    $sqlScriptQueryRule = [SqlScriptQueryRule]::New( $StigRule )

    $ruleType = $sqlScriptQueryRule.GetRuleType( $sqlScriptQueryRule.splitCheckContent )

    $fixText = [SqlScriptQueryRule]::GetFixText( $StigRule )

    $sqlScriptQueryRule.SetGetScript( $ruleType )

    $sqlScriptQueryRule.SetTestScript( $ruleType )

    $sqlScriptQueryRule.SetSetScript( $ruleType, $fixText )

    if ( $sqlScriptQueryRule.IsDuplicateRule( $global:stigSettings ) )
    {
        $sqlScriptQueryRule.SetDuplicateTitle()
    }

    return $sqlScriptQueryRule
}
#endregion
