#region Header
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\Common\Common.psm1
using module .\..\Convert.Stig\Convert.Stig.psm1
#endregion
#region Class
Class SqlScriptQueryRule : STIG
{
    [string] $GetScript

    [string] $TestScript

    [string] $SetScript

    # Constructors
    SqlScriptQueryRule ( [xml.xmlelement] $StigRule )
    {
        $this.InvokeClass( $StigRule )
    }

    [void] SetGetScript ( [string] $RuleType )
    {
        $thisGetScript = & Get-$($RuleType)GetScript -CheckContent $this.SplitCheckContent

        if ( -not $this.SetStatus( $thisGetScript ) )
        {
            $this.set_GetScript( $thisGetScript )
        }
    }

    [void] SetTestScript ( $RuleType )
    {
        $thisTestScript = & Get-$($RuleType)TestScript -CheckContent $this.SplitCheckContent

        if ( -not $this.SetStatus( $thisTestScript ) )
        {
            $this.set_TestScript( $thisTestScript )
        }
    }

    [void] SetSetScript ( [string] $RuleType, [string[]] $FixText )
    {
        $checkContent = $this.SplitCheckContent

        $thisSetScript = & Get-$($RuleType)SetScript -FixText $FixText -CheckContent $checkContent

        if ( -not $this.SetStatus( $thisSetScript ) )
        {
            $this.set_SetScript( $thisSetScript )
        }
    }

    [string] GetRuleType ( [string[]] $CheckContent )
    {
        $ruleType = Get-SqlRuleType -CheckContent $CheckContent

        return $ruleType
    }
}
#endregion
#region Footer
Foreach ($supportFile in (Get-ChildItem -Path $PSScriptRoot -Exclude $MyInvocation.MyCommand.Name))
{
    Write-Verbose "Loading $($supportFile.FullName)"
    . $supportFile.FullName
}
Export-ModuleMember -Function '*' -Variable '*'
#endregion
